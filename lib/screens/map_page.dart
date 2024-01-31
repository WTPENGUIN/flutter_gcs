import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/vehicle_marker.dart';
import 'package:peachgs_flutter/utils/utils.dart';

class MapWindow extends StatefulWidget {
  const MapWindow({Key? key}) : super(key: key);

  @override
  State<MapWindow> createState() => _MapWindowState();
}

class _MapWindowState extends State<MapWindow> {
  List<Marker> vehiclesPosition(MultiVehicle multiVehicleManager) {
    List<Marker> markers = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      markers.add(
        Marker(
          point: LatLng(vehicle.latitude, vehicle.longitude),
          width: 70 * scaleSmallDevice(context),
          height: 70 * scaleSmallDevice(context),
          child: GestureDetector(
            child: VehicleMarker(
              route: 'assets/svg/VehicleIcon.svg',
              radians: vehicle.yaw,
              vehicleId: vehicle.vehicleId,
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
    return Consumer<MultiVehicle>(
      builder: (_, multiManager, __) {
        return _buildMap(multiManager);
      }
    );
  }

  Widget _buildMap(MultiVehicle multiManager) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(34.610040, 127.20674),
        initialZoom: 15,
        onTap: (TapPosition tapPosition, LatLng coord) {

        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: CancellableNetworkTileProvider()
        ),
        MarkerLayer(
          markers: vehiclesPosition(multiManager)
        )
      ]
    );
  }
}
