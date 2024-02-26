import 'dart:io';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink_protocol.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';

const String udpServerProtocol = 'udpserver';
const String disconnectUDPServerMessage = 'UDPSERVERDIS';

class UdpClient {
  InternetAddress address;
  int port;

  UdpClient(this.address, this.port);
}

class UdpServerTask extends LinkTask {
  RawDatagramSocket? udpSocket;
  final MavlinkProtocol mavlink = MavlinkProtocol();
  final Logger logger = Logger();

  String hostName = '';
  int    portNum = 0;

  UdpServerTask(ReceivePort receivePort) : super(receivePort);

  final List<UdpClient> clients = [];

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

        // UDP 패킷에 새로운 주소와 포트번호가 있으면 리스트에 추가
        if(!_isContainList(frame.address, frame.port)) {
          UdpClient client = UdpClient(frame.address, frame.port);
          clients.add(client);
        }
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
      MavlinkFrame frame = message as MavlinkFrame;
      for(UdpClient client in clients) {
        udpSocket!.send(frame.serialize(), client.address, client.port);
      }
    } else {
      logger.i(message);
    }
  }

  // 해당 주소와 포트가 리스트에 있는지 검사
  bool _isContainList(InternetAddress address, int port) {
    for(UdpClient client in clients) {
      if(client.address == address && client.port == port) {
        return true;
      }
    }

    return false;
  }
}