import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:dart_mavlink/dialects/common.dart';

class CommUtils extends ChangeNotifier {
  late RawDatagramSocket _udpSocket;
  late Socket _tcpSocket;
  final MavlinkParser _mavlinkParser = MavlinkParser(MavlinkDialectCommon());

  final Vehicle vehicle = Vehicle();

  CommUtils() {
    _mavlinkParser.stream.listen((MavlinkFrame frm) {
      _mavlinkParsing(frm);
    });
  }

  Future<void> initializeUdpSocket(String serverAddress, int serverPort) async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, serverPort);

    _udpSocket.listen((RawSocketEvent event) {
      if(event != RawSocketEvent.read) return;

      Datagram? frame = _udpSocket.receive();
      if(frame == null) return;

      _handleUdpData(frame);
    });
  }

  // Future<void> initializeTcpSocket(String serverAddress, int serverPort) async {
  //   _tcpSocket = await Socket.connect(serverAddress, serverPort);
  //   _tcpSocket.listen(
  //     (List<int> data) {
  //       _handleTcpData(data);
  //     },
  //     onDone: () {
  //       print('TCP Socket Closed');
  //     },
  //     onError: (error) {
  //       print('TCP Socket Error: $error');
  //     },
  //     cancelOnError: true,
  //   );
  // }

  void _handleUdpData(Datagram event) {
    _mavlinkParser.parse(event.data);
  }

  // void _handleTcpData(List<int> data) {
  //   Uint8List converted = Uint8List.fromList(data);

  //   _mavlinkParser.parse(converted);
  // }

  void _mavlinkParsing(MavlinkFrame frm) {
    switch (frm.message.runtimeType) {
      case GlobalPositionInt:
        var positionInt = frm.message as GlobalPositionInt;
        
        vehicle.latitude = (positionInt.lat / 10e6);
        vehicle.longitude = (positionInt.lon / 10e6);
        vehicle.relativeAltitude = positionInt.relativeAlt;
        break;
      default:
        break;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _udpSocket.close();
    _tcpSocket.close();
    super.dispose();
  }
}