import 'dart:io';
import 'dart:isolate';
import 'package:dart_mavlink/mavlink.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/utils/mavlink_protocol.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';

const String udpServerProtocol = 'udpserver';
const String disconnectUDPServerMessage = 'UDPSERVERDIS';

// TODO : 메세지 보낼 때, Datagram에서 주소 추출하기
class UdpServerTask extends LinkTask {
  RawDatagramSocket? udpSocket;
  final MavlinkProtocol mavlink = MavlinkProtocol();
  final Logger logger = Logger();

  String hostName = '';
  int    portNum = 0;

  UdpServerTask(ReceivePort receivePort) : super(receivePort);

  @override
  void startTask(String host, int port) async {
    hostName = host; // Not Used.
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
  String getProtocol() => udpServerProtocol;

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
    if(message == disconnectUDPServerMessage) {
      stopTask();
    } else if(message.runtimeType == MavlinkFrame) {
      // Send Mavlink Message to socket
    } else {
      logger.i(message);
    }
  }
}