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

  List<NLatLng> convertNaverPoint(List<LatLng> coords) {
    List<NLatLng> list = [];
    for(LatLng coord in coords) {
      list.add(
        NLatLng(coord.latitude, coord.longitude)
      );
    }

    return list;
  }

  void drawMarker() {
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

    _updateLocTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      drawMarker();
    });
  }

  @override
  void dispose() {
    _updateLocTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
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
    );
  }
}

