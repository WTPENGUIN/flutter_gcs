import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:peachgs_flutter/utils/location_service.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/vehicle_info.dart';
import 'package:peachgs_flutter/widget/flyview_tools.dart';
import 'package:peachgs_flutter/widget/planview_tools.dart';
import 'package:peachgs_flutter/screens/video/video.dart';

class MobileBody extends StatefulWidget {
  const MobileBody({Key? key}) : super(key: key);

  @override
  State<MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends State<MobileBody> {
  final OverlayPortalController _overlayPortalController = OverlayPortalController();
  double _posTapDx = 0.0;
  double _posTapDy = 0.0;
  LatLng _posTapCoord = const LatLng(0, 0);

  NaverMapController?     _mapController;
  final LocationService   _loc = LocationService();
  late final MultiVehicle _multivehicle;

  LatLng _initCoord   = const LatLng(36.432383, 127.395036); // 지도 초기 위치

  bool _showFly = true;

  void _setFlyMode() {
    setState(() {
      _showFly = true;
    });
  }

  void _setPlanMode() {
    setState(() {
      _showFly = false;
    });
  }

  // LatLng List를 NLatLng List로 변환
  List<NLatLng> _convertPoint(List<LatLng> coords) {
    List<NLatLng> list = [];
    for(LatLng coord in coords) {
      list.add(
        NLatLng(coord.latitude, coord.longitude)
      );
    }

    return list;
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
          alpha: (vehicle.id == MultiVehicle().getActiveId) ? 1.0 : 0.5, // 활성 기체가 아니면 투명도 적용
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

        // 마커를 클릭하면 활성 기체를 변경하도록 리스너 추가
        mapMarker.setOnTapListener((_) {
          if(MultiVehicle().getActiveId != vehicle.id) {
            _multivehicle.setActiceId = vehicle.id;
          }
        });

        // 생성된 마커를 지도 오버레이에 추가
        _mapController!.addOverlay(mapMarker);

        // 기체 이동 경로 생성
        if((vehicle.route.isNotEmpty) && (vehicle.route.length >= 2)) {
          var mapPath = NPolylineOverlay(
            id: vehicle.id.toString(),
            coords: _convertPoint(vehicle.route),
            color: Colors.red,
            width: 2,
            lineJoin: NLineJoin.round,
            lineCap: NLineCap.butt
          );

          // 생성된 경로를 지도 오버레이에 추가
          _mapController!.addOverlay(mapPath);
        }
      }
    }
  }

  // 지정한 좌표로 지도 이동
  void _moveMap(LatLng vehicleLoc) {
    if(_mapController != null) {
      var cameraUpdate = NCameraUpdate.withParams(
        target: NLatLng(vehicleLoc.latitude, vehicleLoc.longitude)
      );
      _mapController!.updateCamera(cameraUpdate);
    }
  }

  // 이동 명령어 함수
  // TODO : 기체 변환시 마커 레이어 초기화
  void _goto(LatLng coord) {
    var activeVehicle = MultiVehicle().activeVehicle();

    // 활성 기체가 없거나 비행중인 상태가 아니면 동작하지 않음
    if(_mapController == null || activeVehicle == null || !activeVehicle.isFly) return;

    // 지도에 있는 기존 이동 마커 제거 후 새로운 마커 추가
    _mapController!.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'gotoMarker'));

    // 이동 마커 생성
    var gotoMarker = NMarker(
      id: 'gotoMarker',
      position: NLatLng(coord.latitude, coord.longitude),
      size: const Size(50,60),
      caption: const NOverlayCaption(
        text: '이동 지점',
        color:Colors.black,
        haloColor: Colors.white,
        textSize: 15
      )
    );

    // 지도에 이동 마커 추가
    _mapController!.addOverlay(gotoMarker);

    // 활성 기체에 이동 지점으로 이동 명령 전송
    activeVehicle.goto(coord);
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
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: (_) {
        return Positioned(
          top:  _posTapDy,
          left: _posTapDx,
          child: Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.white
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.black45
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.black54,
                  shadowColor: Colors.transparent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                onPressed: () {
                  if(_posTapCoord.latitude == 0 || _posTapCoord.longitude == 0) return;

                  _goto(_posTapCoord);
                  _overlayPortalController.toggle();
                },
                child: const Text(
                  "여기로 이동",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // 네이버 맵 위젯(항상 표시)
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(_initCoord.latitude, _initCoord.longitude),
                zoom: 15
              ),
              scaleBarEnable: false,
              mapType: NMapType.hybrid,
              logoAlign: NLogoAlign.rightTop,
              logoMargin: const EdgeInsets.only(top: 5, right: 5),
            ),
            onMapReady: (NaverMapController controller) {
              _mapController = controller;
            },
            onMapTapped: (NPoint point, NLatLng latLng) {
              // 비행 모드면, 기체 이동 명령 수행
              if(_showFly) {
                var activeVehicle = MultiVehicle().activeVehicle();
                if(activeVehicle != null && activeVehicle.isFly) {
                  _posTapDx = point.x;
                  _posTapDy = point.y;
                  _posTapCoord = LatLng(latLng.latitude, latLng.longitude);

                  _overlayPortalController.toggle();
                }
              }
            }
          ),

          // 비행 모드 도구 모음(비행 모드에서만 표시)
          Visibility(
            visible: _showFly,
            child: FlyViewTools(
              setPlan: _setPlanMode
            )
          ),

          // 임무 모드 도구 모음(비행 모드에서만 표시)
          Visibility(
            visible: !_showFly,
            child: PlanViewTools(
              setFly: _setFlyMode,
              mapCenter: () {
                var currentVehicle = MultiVehicle().activeVehicle();

                if(currentVehicle != null) {
                  var cameraUpdate = NCameraUpdate.withParams(
                    target: NLatLng(currentVehicle.lat, currentVehicle.lon)
                  );
                  _mapController!.updateCamera(cameraUpdate);
                }
              }
            )
          ),

          // TODO : 임무 경로 표시 레이어(임무 모드에서만 표시)

          // 현재 선택한 기체 정보(비행 모드에서만 표시)
          Visibility(
            visible: _showFly,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: VehicleInfo(
                  moveto: _moveMap
                )
              )
            )
          ),

          // 비디오 스트리밍 위젯
          const Align(
            alignment: Alignment.bottomLeft,
            child: VideoViewer(),
          )
        ]
      )
    );
  }
}
