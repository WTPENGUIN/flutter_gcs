import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // final TextEditingController _serverAddressController = TextEditingController();
  // final TextEditingController _serverPortController = TextEditingController();
  // final ValueNotifier<String> _selectedProtocol = ValueNotifier<String>('UDP');

  List<Marker> vehiclesPosition() {
    List<Marker> markers = [];
    for(var vehicle in MultiVehicle().allVehicles()) {
      markers.add(
        Marker(
          point: LatLng(vehicle.latitude, vehicle.longitude),
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
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

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       body: SafeArea(
  //         child: Stack(
  //           children: [
  //             Consumer<MultiVehicle>(
  //               builder: (context, provider, child) {
  //                 return _buildMap(provider);
  //               },
  //             ),
  //             Positioned(
  //               bottom: 0,
  //               left: 0,
  //               child: Container(
  //                 height: MediaQuery.of(context).size.height * 0.25,
  //                 width: MediaQuery.of(context).size.width * 0.4,
  //                 margin: const EdgeInsets.all(5),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(15.0),
  //                   color: const Color(0x99808080)
  //                 ),
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Radio(
  //                             value: 'UDP',
  //                             groupValue: _selectedProtocol.value,
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 _selectedProtocol.value = value as String;
  //                               });
  //                             },
  //                           ),
  //                           const Text('UDP'),
  //                           Radio(
  //                             value: 'TCP',
  //                             groupValue: _selectedProtocol.value,
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 _selectedProtocol.value = value as String;
  //                               });
  //                             },
  //                           ),
  //                           const Text('TCP'),
  //                         ],
  //                       ),
  //                       TextField(
  //                         controller: _serverAddressController,
  //                         decoration: const InputDecoration(labelText: 'Server Address'),
  //                       ),
  //                       TextField(
  //                         controller: _serverPortController,
  //                         keyboardType: TextInputType.number,
  //                         decoration: const InputDecoration(labelText: 'Server Port'),
  //                       ),
  //                       const Padding(padding: EdgeInsets.only(bottom: 10)),
  //                       ElevatedButton(
  //                         onPressed: () async {
  //                           final String serverAddress = _serverAddressController.text;
  //                           final int serverPort = int.tryParse(_serverPortController.text) ?? 0;

  //                           if (serverAddress.isNotEmpty && serverPort > 0) {
  //                             if (_selectedProtocol.value == 'TCP') {
  //                               await Provider.of<LinkTaskManager>(context, listen: false).startTCPTask(serverAddress, serverPort);
  //                             } else {
  //                               await Provider.of<LinkTaskManager>(context, listen: false).startUDPTask(serverAddress, serverPort);
  //                             }
  //                           }
  //                         },
  //                         child: const Text('포트 개방')
  //                       )
  //                     ],
  //                   ),
  //                 )
  //               )
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //}
}
