import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:peachgs_flutter/utils/current_location.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/screens/flyview/flyview_buttons.dart';

class FlyViewDesktopPage extends StatefulWidget {
  const FlyViewDesktopPage({Key? key}) : super(key: key);

  @override
  State<FlyViewDesktopPage> createState() => _FlyViewDesktopPageState();
}

class _FlyViewDesktopPageState extends State<FlyViewDesktopPage> {
  late final MapController _mapController;
  final List<Marker>       _gotoMarker = [];
  bool _buttonPressed = false;

  final CurrentLocation _loc = CurrentLocation();

  List<Marker> _markers(MultiVehicle manager) {
    List<Marker> markers = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      double markerLat = vehicle.lat;
      double markerLon = vehicle.lon;

      if((markerLat == 0) || (markerLon == 0)) continue;
      markers.add(
        Marker(
          point: LatLng(markerLat, markerLon),
          width: 70,
          height: 70,
          child: GestureDetector(
            child: VehicleMarker(
              route: 'assets/image/VehicleIcon.svg',
              degree: vehicle.yaw,
              vehicleId: vehicle.id,
              flightMode: vehicle.mode,
              armed: vehicle.armed,
              outlineColor: (manager.getActiveId == vehicle.id ? Colors.redAccent : Colors.grey),
            ),
            onTap: () {
              if(manager.getActiveId == vehicle.id) return;
              manager.setActiceId = vehicle.id;
            },
          ),
        )
      );
    }
    return markers;
  }

  List<Polyline> _route(MultiVehicle manager) {
    List<Polyline> lines = [];
    for(var vehicle in manager.allVehicles()) {
      if(vehicle.route.isEmpty) continue;

      lines.add(Polyline(
        points: vehicle.route,
        color: Colors.red,
        strokeWidth: 3.0
      ));
    }

    return lines;
  }

  @override
  void initState() {
    super.initState();
    
    _mapController = MapController();
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
        initialCenter: const LatLng(34.610040, 127.20674),
        initialZoom: 15,
        onMapReady: () async {
          bool isGetCoord = await _loc.getCurrentLocation();
          if(isGetCoord) {
            _mapController.move(LatLng(_loc.latitude, _loc.longitude), 15);
          }
        },
        onTap: (TapPosition position, LatLng point) {
          // 이동 버튼이 눌렸을 때
          if(_buttonPressed) {
            var currentVehicle = MultiVehicle().activeVehicle();

            if(currentVehicle != null) {
              if(currentVehicle.isFly) {
                // 이동할 곳 마커 찍기
                setState(() {
                  _gotoMarker.clear();
                  _gotoMarker.add(
                    Marker(
                      point: point,
                      child: const Icon(Icons.location_pin, color: Colors.red),
                      alignment: Alignment.center
                    )
                  );
                });
              
                // 클릭한 포인트로 이동 명령 내리기
                currentVehicle.goto(point);

                // 버튼 눌리지 않은 상태로 설정
                setState(() {
                  _buttonPressed = false;
                });
              }
            }
          }
        },
      ),
      children: [
        // 구글 지도 레이어
        TileLayer(
          wmsOptions: WMSTileLayerOptions(
            baseUrl: 'https://mt0.google.com/vt/lyrs=y@221097413&x={x}&y={y}&z={z}',
          ),
          tileProvider: CancellableNetworkTileProvider(),
        ),

        // 기체 위치 표시 레이어
        Consumer<MultiVehicle>(
          builder: (_, multiManager, __) {
            return MarkerLayer(
              markers: _markers(multiManager)
            );
          },
        ),

        // 기체 이동 경로 표시 레이어
        Consumer<MultiVehicle>(
          builder: (_, multiManager, __) {
            return PolylineLayer(
              polylines: _route(multiManager),
            );
          }
        ),

        // 이동 명령 마커 레이어
        MarkerLayer(markers: _gotoMarker),

        // 도구 모음 버튼
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: FlyViewButtons(
              buttonState: _buttonPressed,
              mapSubmit: () {
                setState(() {
                  _buttonPressed = !_buttonPressed;
                });
              }
            )
          )
        )
      ]
    );
  }
}
