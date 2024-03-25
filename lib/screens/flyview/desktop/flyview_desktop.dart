import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:peachgs_flutter/utils/location_service.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/screens/flyview/flyview_buttons.dart';
import 'package:peachgs_flutter/screens/flyview/flyview_info.dart';

class FlyViewDesktop extends StatefulWidget {
  const FlyViewDesktop({Key? key}) : super(key: key);

  @override
  State<FlyViewDesktop> createState() => _FlyViewDesktopState();
}

class _FlyViewDesktopState extends State<FlyViewDesktop> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  double _posTapDx = 0.0;
  double _posTapDy = 0.0;
  LatLng _posTapCoord = const LatLng(0, 0);

  final MapController   _mapController = MapController();
  final LocationService _loc           = LocationService();
  final List<Marker>    _gotoMarker    = [];

  LatLng _initCoord   = const LatLng(34.610040, 127.20674); // 지도 초기 위치

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
          child: GestureDetector(
            child: VehicleMarker(
              vehicleId: vehicle.id,
              flightMode: vehicle.mode,
              armed: vehicle.armed,
              degree: vehicle.yaw,
              outlineColor: (manager.getActiveId == vehicle.id ? Colors.redAccent : Colors.grey),
            ),
            onTap: () {
              // 마커를 클릭하면 활성 기체를 변경
              if(manager.getActiveId != vehicle.id) {
                manager.setActiceId = vehicle.id;
              }
            },
          ),
        )
      );
    }
    return markers;
  }

  // 기체 이동 경로 그리기
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

  // 지정한 좌표로 지도 이동
  void _moveTo(LatLng loc) {
    var currentZoom = _mapController.camera.zoom;
    _mapController.move(loc, currentZoom);
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
    return OverlayPortal(
      controller: _overlayController,
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

                  var activeVehcile = MultiVehicle().activeVehicle();
                  if(activeVehcile != null) {
                    activeVehcile.goto(_posTapCoord);
                  }
                  _overlayController.toggle();
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
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initCoord,
          initialZoom: 15,
          onTap: (TapPosition tapPosition, LatLng point) {
            if(MultiVehicle().activeVehicle() == null) return;
            
            var activeVehcile = MultiVehicle().activeVehicle();
            if(activeVehcile!.isFly) {
              _posTapDx = tapPosition.global.dx;
              _posTapDy = tapPosition.global.dy;
              _posTapCoord = point;
              
              _overlayController.toggle();
            }
          },
        ),
        children: [
          // 구글 지도 레이어
          TileLayer(
            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'https://mt0.google.com/vt/lyrs=y&hl=kr&x={x}&y={y}&z={z}',
            ),
            tileProvider: CancellableNetworkTileProvider(),
          ),

          // 기체 위치 표시 레이어
          Consumer<MultiVehicle>(
            builder: (_, multiManager, __) {
              return MarkerLayer(
                markers: _markers(multiManager)
              );
            }
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

          // 데스크톱 플라이뷰 도구 모음
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FlyViewButtons()
            )
          ),

          // 현재 선택한 기체 정보
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FlyViewInfo(
                moveto: _moveTo
              )
            )
          )
        ],
      ),
    );
  }
}
