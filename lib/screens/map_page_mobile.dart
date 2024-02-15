import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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

  void drawMarker() {
    if(_mapController != null) {
      var vehicleList = multivehicle.allVehicles();

      if(vehicleList.isEmpty) {
        _mapController!.clearOverlays();
      } else {
        for(var vehicle in multivehicle.allVehicles()) {
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

          _mapController!.addOverlay(marker);
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

