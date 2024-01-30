import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/svg_image.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> vehiclesPosition() {
    List<Marker> markers = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      markers.add(
        Marker(
          point: LatLng(vehicle.latitude, vehicle.longitude),
          child: SVGImage(
            route: 'assets/svg/VehicleIcon.svg',
            size: const Size(100,100),
            radians: vehicle.yaw,
          )
        )
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiVehicle>(
      builder: (context, provider, child) {
        return _buildMap(provider);
      }
    );
  }

  Widget _buildMap(MultiVehicle provider) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(34.610040, 127.20674),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: CancellableNetworkTileProvider()
        ),
        MarkerLayer(
          markers: vehiclesPosition()
        )
      ]
    );
  }
}
