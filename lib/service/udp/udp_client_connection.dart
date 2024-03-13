import 'dart:io';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink/mavlink_protocol.dart';
import 'package:peachgs_flutter/service/connection/connection_task.dart';

const String udpClientProtocol          = 'udpclient';
const String disconnectUDPClientMessage = 'UDPCLIENTDIS';

class UdpClientTask extends LinkTask {
  UdpClientTask(ReceivePort receivePort) : super(receivePort);
  
  RawDatagramSocket?    _udpSocket;
  final MavlinkProtocol _mavlink = MavlinkProtocol();

  String _hostName = '';
  int    _portNum = 0;

  @override
  void startTask(String host, int port) async {
    _hostName = host;
    _portNum = port;

    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _udpSocket!.listen((RawSocketEvent event) {
      if(event != RawSocketEvent.read) return;

      Datagram? frame = _udpSocket!.receive();
      if(frame == null) {
        return;
      } else {
        _mavlink.parser.parse(frame.data);
      }
    });

    receivePort.listen((dynamic message) {
      processMessage(message);
    });

    Logger().i('start udp task');
  }

  @override
  String getProtocol() => udpClientProtocol;

  @override
  String getHost() => _hostName;

  @override
  int getPortNum() => _portNum;

  @override
  ReceivePort getMessagePort() => receivePort;

  @override
  void stopTask() {
    if(_udpSocket != null) {
      _udpSocket!.close();
      Logger().i('stop udp task');
    }
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectUDPClientMessage) {
      stopTask();
    } else if(message.runtimeType == MavlinkFrame) {
      MavlinkFrame frame = message as MavlinkFrame;
      _udpSocket!.send(frame.serialize(), InternetAddress(_hostName), _portNum);
    } else {
      Logger().i(message);
    }
  }
}