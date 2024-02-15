import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/utils/utils.dart';

class MapWindowMobile extends StatefulWidget {
  const MapWindowMobile({Key? key}) : super(key: key);

  @override
  State<MapWindowMobile> createState() => _MapWindowMobileState();
}

class _MapWindowMobileState extends State<MapWindowMobile> {
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(34.610040, 127.20674),
          zoom: 15
        ),
        mapType: NMapType.hybrid,
      ),
      forceGesture: false,
      onMapReady:(controller) {
        logger.i('네이버 맵 로딩');
      },
    );
  }
}