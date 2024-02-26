import 'dart:io';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink_protocol.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';

const String udpClientProtocol = 'udpclient';
const String disconnectUDPClientMessage = 'UDPCLIENTDIS';

class UdpClientTask extends LinkTask {
  RawDatagramSocket? udpSocket;
  final MavlinkProtocol mavlink = MavlinkProtocol();
  final Logger logger = Logger();

  String hostName = '';
  int    portNum = 0;

  UdpClientTask(ReceivePort receivePort) : super(receivePort);

  @override
  void startTask(String host, int port) async {
    hostName = host;
    portNum = port;

    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    udpSocket!.listen((RawSocketEvent event) {
      if(event != RawSocketEvent.read) return;

      Datagram? frame = udpSocket!.receive();
      if(frame == null) {
        return;
      } else {
        mavlink.parser.parse(frame.data);
      }
    });

    receivePort.listen((dynamic message) {
      processMessage(message);
    });

    logger.i('start udp task');
  }

  @override
  String getProtocol() => udpClientProtocol;

  @override
  String getHost() => hostName;

  @override
  int getPortNum() => portNum;

  @override
  ReceivePort getMessagePort() => receivePort;

  @override
  void stopTask() {
    if(udpSocket != null) {
      udpSocket!.close();
      logger.i('stop udp task');
    }
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectUDPClientMessage) {
      stopTask();
    } else if(message.runtimeType == MavlinkFrame) {
      MavlinkFrame frame = message as MavlinkFrame;
      udpSocket!.send(frame.serialize(), InternetAddress(hostName), portNum);
    } else {
      logger.i(message);
    }
  }
}