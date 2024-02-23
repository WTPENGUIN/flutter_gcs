import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/utils/utils.dart';
import 'package:peachgs_flutter/utils/current_location.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/vehicle_marker.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/fly_buttons.dart';

class MapWindowDesktop extends StatefulWidget {
  const MapWindowDesktop({Key? key}) : super(key: key);

  @override
  State<MapWindowDesktop> createState() => _MapWindowDesktopState();
}

class _MapWindowDesktopState extends State<MapWindowDesktop> {
  Logger logger = Logger();

  late final MapController _mapController;
  final List<Marker> guidedModeMarkers = [];
  bool _isGotoButtonPressed = false;

  final CurrentLocation _loc = CurrentLocation();

  List<Marker> vehiclesPosition(MultiVehicle multiVehicleManager) {
    List<Marker> markers = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      double markerLat = vehicle.vehicleLat;
      double markerLon = vehicle.vehicleLon;

      if((markerLat == 0) || (markerLon == 0)) continue;
      markers.add(
        Marker(
          point: LatLng(markerLat, markerLon),
          width: 70 * scaleSmallDevice(context),
          height: 70 * scaleSmallDevice(context),
          child: GestureDetector(
            child: VehicleMarker(
              route: 'assets/image/VehicleIcon.svg',
              degree: vehicle.yaw,
              vehicleId: vehicle.vehicleId,
              flightMode: vehicle.flightMode,
              armed: vehicle.armed,
              outlineColor: (multiVehicleManager.getActiveId == vehicle.vehicleId ? Colors.redAccent : Colors.grey),
            ),
            onTap: () {
              if(multiVehicleManager.getActiveId == vehicle.vehicleId) return;
              multiVehicleManager.setActiceId = vehicle.vehicleId;
            },
          ),
        )
      );
    }
    return markers;
  }

  List<Polyline> vehiclesTrajectoryList(MultiVehicle multiVehicleManager) {
    List<Polyline> lines = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      if(vehicle.trajectoryList.isEmpty) continue;

      lines.add(Polyline(
        points: vehicle.trajectoryList,
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
          if(_isGotoButtonPressed) {
            var currentVehicle = MultiVehicle().activeVehicle();

            if(currentVehicle != null) {
              if(currentVehicle.isFlying) {
                // 이동할 곳 마커 찍기
                setState(() {
                  guidedModeMarkers.clear();
                  guidedModeMarkers.add(
                    Marker(
                      point: point,
                      child: const Icon(Icons.location_pin, color: Colors.red),
                      alignment: Alignment.center
                    )
                  );
                });
              
                // 클릭한 포인트로 이동 명령 내리기
                currentVehicle.vehicleGuidedModeGotoLocation(point);

                // 버튼 눌리지 않은 상태로 설정
                setState(() {
                  _isGotoButtonPressed = false;
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
              markers: vehiclesPosition(multiManager)
            );
          },
        ),

        // 기체 이동 경로 표시 레이어
        Consumer<MultiVehicle>(
          builder: (_, multiManager, __) {
            return PolylineLayer(
              polylines: vehiclesTrajectoryList(multiManager),
            );
          }
        ),

        // 이동 명령 마커 레이어
        MarkerLayer(markers: guidedModeMarkers),

        //도구 모음 버튼
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: FlyButtons(
              buttonState: _isGotoButtonPressed,
              mapSubmit: () {
                setState(() {
                  _isGotoButtonPressed = !_isGotoButtonPressed;
                });
              },
            ),
          )
        )
      ]
    );
  }
}
