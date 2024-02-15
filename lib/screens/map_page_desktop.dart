import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/utils/utils.dart';

class MapWindowDesktop extends StatefulWidget {
  const MapWindowDesktop({Key? key}) : super(key: key);

  @override
  State<MapWindowDesktop> createState() => _MapWindowDesktopState();
}

class _MapWindowDesktopState extends State<MapWindowDesktop> {
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
              radians: vehicle.yaw,
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(34.610040, 127.20674),
        initialZoom: 15,
        onTap: (TapPosition tapPosition, LatLng coord) {
          
        },
      ),
      children: [
        TileLayer(
          wmsOptions: WMSTileLayerOptions(
            baseUrl: 'https://{s}.s2maps-tiles.eu/wms/?',
            layers: const ['s2cloudless-2021_3857'],
          ),
          subdomains: const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
          tileProvider: CancellableNetworkTileProvider(),
        ),
        Consumer<MultiVehicle>(
          builder:(_, multiManager, __) {
            return MarkerLayer(
              markers: vehiclesPosition(multiManager)
            );
          },
        )
      ]
    );
  }
}
