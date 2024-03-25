import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:peachgs_flutter/utils/location_service.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/screens/planview/planview_buttons.dart';


class PlanViewMobile extends StatefulWidget {
  const PlanViewMobile({Key? key}) : super(key: key);

  @override
  State<PlanViewMobile> createState() => _PlanViewMobileState();
}

class _PlanViewMobileState extends State<PlanViewMobile> {
  late final MultiVehicle _multivehicle;
  final LocationService   _loc = LocationService();
  NaverMapController?     _mapController;

  bool   _wayPointPressed = false;                        // 웨이포인트 버튼 누름 상태
  LatLng _initCoord = const LatLng(34.610040, 127.20674); // 지도 초기 위치

  // 지도를 활성 기체의 중앙으로 이동
  void _vehicleMapCenter() {
    var currentVehicle = MultiVehicle().activeVehicle();

    if(currentVehicle != null) {
      if(_mapController != null) {
        var cameraUpdate = NCameraUpdate.withParams(
          target: NLatLng(currentVehicle.lat, currentVehicle.lon)
        );
        _mapController!.updateCamera(cameraUpdate);
      }
    }
  }

  // 지도에 현재 연결된 기체들의 마커 그리기
  void _drawVehicle() {
    if(_mapController == null) return;

    var vehicleList = _multivehicle.allVehicles();
    if(vehicleList.isEmpty) {
      _mapController!.clearOverlays();
    } else {
      for(var vehicle in vehicleList) {
        double markerLat = vehicle.lat;
        double markerLon = vehicle.lon;

        if((markerLat == 0) || (markerLon == 0)) continue;
        
        // 기체 마커 생성
        var mapMarker = NMarker(
          id: vehicle.id.toString(),
          icon: const NOverlayImage.fromAssetImage('assets/image/VehicleIcon.png'),
          size: const Size(70, 70),
          anchor: const NPoint(0.5, 0.5), // 기본 마커는 위로 살짝 올라와 있기 때문에 재조정
          angle: vehicle.yaw,
          position: NLatLng(vehicle.lat, vehicle.lon),
          alpha: (vehicle.id != MultiVehicle().getActiveId) ? 0.5 : 1.0, // 활성 기체가 아니면 투명도 적용
          caption: NOverlayCaption(
            text: '기체 ${vehicle.id} (${(vehicle.armed) ? '시동' : '꺼짐'})',
            color: (_multivehicle.getActiveId == vehicle.id) ? Colors.white : Colors.black,
            haloColor: (_multivehicle.getActiveId == vehicle.id) ? Colors.red : Colors.white,
            textSize: 15
          ),
          subCaption: NOverlayCaption(
            text: '모드 ${vehicle.mode}',
            color: (_multivehicle.getActiveId == vehicle.id) ? Colors.white : Colors.black,
            haloColor: (_multivehicle.getActiveId == vehicle.id) ? Colors.red : Colors.white,
            textSize: 13
          )
        );
        
        // 생성된 마커를 지도 오버레이에 추가
        _mapController!.addOverlay(mapMarker);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // 사용자 위치 가져오기
    if(_loc.isGetCoord) {
      _initCoord = LatLng(_loc.latitude, _loc.longitude);
    }

    // MultiVehicle 데이터 변경 리스너 추가
    _multivehicle = context.read<MultiVehicle>();
    _multivehicle.addListener(_drawVehicle);
  }

  @override
  void dispose() {
    // MultiVehicle 데이터 변경 리스너 제거
    _multivehicle.removeListener(_drawVehicle);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(_initCoord.latitude, _initCoord.longitude),
              zoom: 15
            ),
            mapType: NMapType.hybrid,
            scaleBarEnable: false,
            logoAlign: NLogoAlign.rightTop,
            logoMargin: const EdgeInsets.only(top: 5, right: 5),
          ),
          onMapReady: (controller) {
            _mapController = controller;
            _vehicleMapCenter(); // 현재 활성 기체의 위치로 맵 이동
          },
          onMapTapped: (_, latLng) {
            // TODO : 웨이포인트 추가 버튼을 누른 상태이면 웨이포인트 추가
          },
        ),

        // 모바일 플랜뷰 도구 모음
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: PlanViewButtons(
              takeOffPressed: () {},
              wayPointState: _wayPointPressed,
              wayPointPressed: () {
                setState(() {
                  _wayPointPressed = !_wayPointPressed;
                });
              },
              rtlPressed: () {},
              mapCenterPressed: _vehicleMapCenter,
            ),
          ),
        )
      ]
    );
  }
}