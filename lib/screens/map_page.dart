import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:peachgs_flutter/utils/comm_utils.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final TextEditingController _serverAddressController = TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Consumer<CommUtils>(
                builder: (context, provider, child) {
                  return _buildMap(provider);
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: const Color(0x99808080)
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _serverAddressController,
                          decoration: const InputDecoration(labelText: 'Server Address'),
                        ),
                        TextField(
                          controller: _serverPortController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Server Port'),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        ElevatedButton(
                          onPressed: () async {
                            final String serverAddress = _serverAddressController.text;
                            final int serverPort = int.tryParse(_serverPortController.text) ?? 0;

                            if (serverAddress.isNotEmpty && serverPort > 0) {
                              await Provider.of<CommUtils>(context, listen: false).initializeUdpSocket(serverAddress, serverPort);
                              //await Provider.of<CommUtils>(context, listen: false).initializeTcpSocket(serverAddress, serverPort);
                            }
                          },
                          child: const Text('포트 개방')
                        )
                      ],
                    ),
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap(CommUtils provider) {
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
          markers: [
            Marker(
              point: LatLng(provider.vehicle.latitude, provider.vehicle.longitude),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
              )
            )
          ]
        )
      ]
    );
  }
}
