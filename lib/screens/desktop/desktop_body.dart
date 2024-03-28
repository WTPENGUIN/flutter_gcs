import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'package:peachgs_flutter/utils/location_service.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/widget/vehicle_info.dart';
import 'package:peachgs_flutter/widget/flyview_tools.dart';
import 'package:peachgs_flutter/widget/planview_tools.dart';
import 'package:peachgs_flutter/screens/video/video.dart';

class DesktopBody extends StatefulWidget {
  const DesktopBody({super.key});

  @override
  State<DesktopBody> createState() => _DesktopBodyState();
}

class _DesktopBodyState extends State<DesktopBody> {
  final OverlayPortalController _overlayPortalController = OverlayPortalController();
  double _posTapDx = 0.0;
  double _posTapDy = 0.0;
  LatLng _posTapCoord = const LatLng(0, 0);

  final MapController   _mapController = MapController();
  final LocationService _location      = LocationService();
  final List<Marker>    _gotoMarker    = [];

  LatLng _mapInitCoord = const LatLng(36.432383, 127.395036); // 지도 초기 위치

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

  // 지도에 현재 연결된 기체들의 마커 리스트 생성
  List<Marker> _markers() {
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
              translucent: (MultiVehicle().getActiveId != vehicle.id), // 현재 활성화된 기체가 아니면 반투명 적용
              outlineColor: (MultiVehicle().getActiveId == vehicle.id ? Colors.redAccent : Colors.grey),
            ),
            onTap: () {
              // 마커를 클릭하면 활성 기체를 변경
              if(MultiVehicle().getActiveId != vehicle.id) {
                MultiVehicle().setActiceId = vehicle.id;
              }
            },
          ),
        )
      );
    }
    return markers;
  }

  // 기체 이동 경로 그리기
  List<Polyline> _route() {
    List<Polyline> lines = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
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
  void _moveMap(LatLng loc) {
    var currentZoom = _mapController.camera.zoom;
    _mapController.move(loc, currentZoom);
  }

  @override
  void initState() {
    super.initState();

    // 사용자 위치 가져오기
    if(_location.isGetCoord) {
      _mapInitCoord = LatLng(_location.latitude, _location.longitude);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: (_) {
        // 지도 클릭 시 팝업 생성
        return Positioned(
          top: _posTapDy,
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
                  
                  _overlayPortalController.toggle();
                },
                child: const Text(
                  '여기로 이동',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          )
        );
      },
      child: FlutterMap(
         mapController: _mapController,
         options: MapOptions(
          initialCenter: _mapInitCoord,
          initialZoom: 15,
          onTap: (TapPosition tapPosition, LatLng point) {
            // 비행 모드면, 기체 이동 명령 수행
            if(_showFly) {
              var activeVehcile = MultiVehicle().activeVehicle();
              if(activeVehcile != null && activeVehcile.isFly) {
                _posTapDx = tapPosition.global.dx;
                _posTapDy = tapPosition.global.dy;
                _posTapCoord = point;

                _overlayPortalController.toggle();
              }
            }
          },
        ),
        children: [
          // 구글 WMS 지도 레이어(항상 표시)
          TileLayer(
            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'https://mt0.google.com/vt/lyrs=y&hl=kr&x={x}&y={y}&z={z}',
            ),
            tileProvider: CancellableNetworkTileProvider(),
          ),
          
          // 기체 위치 표시 레이어(항상 표시)
          Consumer<MultiVehicle>(
            builder: (_, multiManager, __) {
              return MarkerLayer(
                markers: _markers()
              );
            }
          ),

          // 비행 모드 도구 모음(비행 모드에서만 표시)
          Visibility(
            visible: _showFly,
            child: FlyViewTools(
              setPlan: _setPlanMode
            )
          ),

          // 임무 모드 도구 모음(임무 모드에서만 표시)
          Visibility(
            visible: !_showFly,
            child: PlanViewTools(
              setFly: _setFlyMode,
              mapCenter: () {
                var currentVehicle = MultiVehicle().activeVehicle();

                if(currentVehicle != null) {
                  var zoom = _mapController.camera.zoom;
                  _mapController.move(LatLng(currentVehicle.lat, currentVehicle.lon), zoom);
                }
              },
            ),
          ),

          // 기체 이동 경로 표시 레이어(비행 모드에서만 표시)
          Visibility(
            visible: _showFly,
            child: Consumer<MultiVehicle>(
              builder: (_, multiManager, __) {
                return PolylineLayer(
                  polylines: _route(),
                );
              }
            )
          ),

          // TODO : 임무 경로 표시 레이어(임무 모드에서만 표시)

          // 이동 명령 마커 레이어(비행 모드에서만 표시)
          // TODO : 기체 변환시 마커 레이어 초기화
          Visibility(
            visible: _showFly,
            child: MarkerLayer(markers: _gotoMarker)
          ),

          // 현재 선택한 기체 정보 표시(비행 모드에서만 표시)
          Visibility(
            visible: _showFly,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: VehicleInfo(
                  moveto: _moveMap,
                ),
              ),
            )
          ),
          
          // 비디오 스트리밍 위젯
          const Align(
            alignment: Alignment.bottomLeft,
            child: VideoViewer()
          )
        ]
      )
    );
  }
}
