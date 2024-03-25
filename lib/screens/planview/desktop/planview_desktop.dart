import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:peachgs_flutter/utils/location_service.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/screens/planview/planview_buttons.dart';

class PlanViewDesktop extends StatefulWidget {
  const PlanViewDesktop({Key? key}) : super(key: key);

  @override
  State<PlanViewDesktop> createState() => _PlanViewDesktopState();
}

class _PlanViewDesktopState extends State<PlanViewDesktop> {
  final MapController   _mapController = MapController();
  final LocationService _loc           = LocationService();
  
  bool   _wayPointPressed = false;                              // 웨이포인트 버튼 누름 상태
  LatLng _initCoord       = const LatLng(34.610040, 127.20674); // 지도 초기 위치

  // 지도를 활성 기체의 중앙으로 이동
  void _vehicleMapCenter() {
    var currentVehicle = MultiVehicle().activeVehicle();
    
    if(currentVehicle != null) {
      var zoom = _mapController.camera.zoom;
      _mapController.move(LatLng(currentVehicle.lat, currentVehicle.lon), zoom);
    }
  }

  // 지도에 현재 연결된 기체들의 마커 리스트 생성
  List<Marker> _markers(MultiVehicle manager) {
    List<Marker> markers = [];
    
    for(var vehicle in MultiVehicle().allVehicles()) {
      double markerLat = vehicle.lat;
      double markerLon = vehicle.lon;

      if((markerLat == 0) || (markerLon == 0)) continue;

      // 기체 마커 생성하여 리스트에 추가
      markers.add(
        Marker(
          point: LatLng(markerLat, markerLon),
          width: 70,
          height: 70,
          child: VehicleMarker(
            vehicleId: vehicle.id,
            flightMode: vehicle.mode,
            armed: vehicle.armed,
            degree: vehicle.yaw,
            outlineColor: (manager.getActiveId == vehicle.id ? Colors.redAccent : Colors.grey),
            translucent: (vehicle.id != MultiVehicle().getActiveId),
          )
        )
      );
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();

    // 사용자 위치 가져오기
    if(_loc.isGetCoord) {
      _initCoord = LatLng(_loc.latitude, _loc.longitude);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initCoord,
        initialZoom: 15,
        onMapReady: () {
          _vehicleMapCenter(); // 현재 활성 기체의 위치로 맵 이동
        },
        onTap: (TapPosition position, LatLng point) {
          if(_wayPointPressed) {
            print("Test WayPoint : $point");
          }
        }
      ),
      children: [
        // 구글 지도 레이어
        TileLayer(
          wmsOptions: WMSTileLayerOptions(
            baseUrl: 'https://mt0.google.com/vt/lyrs=y&hl=kr&x={x}&y={y}&z={z}',
          ),
          tileProvider: CancellableNetworkTileProvider()
        ),

        // 기체 위치 표시 레이어
        Consumer<MultiVehicle>(
          builder: (_, multiManager, __) {
            return MarkerLayer(
              markers: _markers(multiManager)
            );
          },
        ),

        // TODO : 기체 임무 경로 표시

        // 데스크톱 플랜뷰 도구 모음
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
              mapCenterPressed: _vehicleMapCenter
            )
          )
        )
      ]
    );
  }
}