import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class MapWindowMobile extends StatefulWidget {
  const MapWindowMobile({Key? key}) : super(key: key);

  @override
  State<MapWindowMobile> createState() => _MapWindowMobileState();
}

class _MapWindowMobileState extends State<MapWindowMobile> {
  NaverMapController? _mapController;
  Logger logger = Logger();

  late final MultiVehicle multivehicle;
  late Timer _updateLocTimer;

  bool _isGotoButtonPressed = false;

  List<NLatLng> convertNaverPoint(List<LatLng> coords) {
    List<NLatLng> list = [];
    for(LatLng coord in coords) {
      list.add(
        NLatLng(coord.latitude, coord.longitude)
      );
    }

    return list;
  }

  void drawVehicleMarker() {
    if(_mapController != null) {
      var vehicleList = multivehicle.allVehicles();

      if(vehicleList.isEmpty) {
        _mapController!.clearOverlays();
      } else {
        for(var vehicle in multivehicle.allVehicles()) {
          double markerLat = vehicle.vehicleLat;
          double markerLon = vehicle.vehicleLon;

          if((markerLat != 0) && (markerLon != 0)) {
            // 기체 마커
            var marker = NMarker(
              id: vehicle.vehicleId.toString(),
              icon: const NOverlayImage.fromAssetImage('assets/image/VehicleIcon.png'),
              size: const Size(70, 70),
              position: NLatLng(vehicle.vehicleLat, vehicle.vehicleLon),
              caption: NOverlayCaption(
                text: '기체 ${vehicle.vehicleId} (${(vehicle.armed) ? '시동' : '꺼짐'})',
                color: (multivehicle.getActiveId == vehicle.vehicleId) ? Colors.white : Colors.black,
                haloColor: (multivehicle.getActiveId == vehicle.vehicleId) ? Colors.red : Colors.white,
                textSize: 15
              ),
              subCaption: NOverlayCaption(
                text: '모드 ${vehicle.flightMode}',
                color: (multivehicle.getActiveId == vehicle.vehicleId) ? Colors.white : Colors.black,
                haloColor: (multivehicle.getActiveId == vehicle.vehicleId) ? Colors.red : Colors.white,
                textSize: 13
              )
            );
            marker.setOnTapListener((_) {
              multivehicle.setActiceId = vehicle.vehicleId;
            });

            // 마커 오버레이에 추가
            _mapController!.addOverlay(marker);
          }

          if(vehicle.trajectoryList.isNotEmpty && (vehicle.trajectoryList.length >= 2)) {
            // 기체 이동 경로
            var path = NPolylineOverlay(
              id: vehicle.vehicleId.toString(),
              coords: convertNaverPoint(vehicle.trajectoryList),
              color: Colors.red,
              width: 2,
              lineJoin: NLineJoin.round,
              lineCap: NLineCap.butt
            );

            // 경로 오버레이에 추가
            _mapController!.addOverlay(path);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    multivehicle = context.read<MultiVehicle>();

    _updateLocTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      drawVehicleMarker();
    });
  }

  @override
  void dispose() {
    _updateLocTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(34.610040, 127.20674),
              zoom: 15
            ),
            mapType: NMapType.hybrid,
            logoAlign: NLogoAlign.rightTop,
            logoMargin: EdgeInsets.only(top: 60),
          ),
          onMapReady: (controller) {
            _mapController = controller;
          },
          onMapTapped: (point, latLng) {
            // 지도가 눌렸을 때 처리
            if(_isGotoButtonPressed && _mapController != null) {
              var currentVehicle = MultiVehicle().activeVehicle();

              if(currentVehicle != null) {
                if(currentVehicle.isFlying) {
                  // 버튼 비활성화 처리
                  setState(() {
                    _isGotoButtonPressed = false;
                  });

                  // 지도에 있던 기존 마커 제거 후 새로운 마커 추가
                  _mapController!.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'clickedMarker'));
                  var locationMarker = NMarker(
                    id: 'clickedMarker',
                    position: latLng,
                    size: const Size(50, 60),
                    caption: const NOverlayCaption(
                      text: '이동 지점',
                      color:Colors.black,
                      haloColor: Colors.white,
                      textSize: 15
                    ),
                  );
                  _mapController!.addOverlay(locationMarker);

                  // 클릭 포인트로 이동 명령 내리기
                  currentVehicle.vehicleGuidedModeGotoLocation(LatLng(latLng.latitude, latLng.longitude));
                }
              }
            }
          },
        ),
        Positioned(
          top: 70,
          left: 10,
          child: SizedBox(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGotoButtonPressed = !_isGotoButtonPressed;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: (_isGotoButtonPressed) ? Colors.blue : Colors.grey
              ),
              child: const Icon(
                Icons.flag,
                color: Colors.white
              ),
            ),
          )
        )
      ],
    );
  }
}

