import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/utils/mavlink_protocol.dart';

const String tcpProtocol = 'tcp';
const String udpProtocol = 'udp';
const String disconnectTCPMessage = 'TCPDIS';
const String disconnectUDPMessage = 'UDPDIS';

abstract class LinkTask {
  ReceivePort receivePort;

  LinkTask(this.receivePort);

  void startTask(String host, int port);
  void stopTask();
  void processMessage(dynamic message);

  String      getProtocol();
  String      getHost();
  int         getPortNum();
  ReceivePort getMessagePort();
}

class LinkTaskManager extends ChangeNotifier {
  final List<LinkTask> _taskList = [];
  final Logger logger = Logger();

  Future<void> startUDPTask(String host, int port) async {
    UdpTask task = UdpTask(ReceivePort());

    _taskList.add(task);
    task.startTask(host, port);
  }

  Future<void> startTCPTask(String host, int port) async {
    TcpTask task = TcpTask(ReceivePort());

    _taskList.add(task);
    task.startTask(host, port);
  }

  void stopUDPTask(String host, int port) {
    for(var task in _taskList) {
      if(task.getProtocol() == udpProtocol) continue;

      if(task.getHost() == host || task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectUDPMessage);
        _taskList.remove(task);
      }
    } 
  }

  void stopTCPTask(String host, int port) {
    for(var task in _taskList) {
      if(task.getProtocol() == tcpProtocol) continue;

      if(task.getHost() == host || task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectTCPMessage);
        _taskList.remove(task);
      }
    }
  }

  void stopAllTask() {
    for(var task in _taskList) {
      if(task.getProtocol() == tcpProtocol) {
        task.receivePort.sendPort.send(disconnectTCPMessage);
      } else {
        task.receivePort.sendPort.send(disconnectUDPMessage);
      }
    }

    _taskList.clear();
  }

  @override
  void dispose() {
    stopAllTask();
    super.dispose();
  }
}

class UdpTask extends LinkTask {
  RawDatagramSocket? udpSocket;
  final MavlinkProtocol mavlink = MavlinkProtocol();
  final Logger logger = Logger();

  String hostName = '';
  int    portNum = 0;

  UdpTask(ReceivePort receivePort) : super(receivePort);

  @override
  void startTask(String host, int port) async {
    hostName = host;
    portNum = port;

    udpSocket = await RawDatagramSocket.bind(InternetAddress(host), port);

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
  String getProtocol() => udpProtocol;

  @override
  String getHost() => hostName;

  @override
  int getPortNum() => portNum;

  @override
  ReceivePort getMessagePort() => receivePort;

  @override
  void stopTask() {
    udpSocket!.close();
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectUDPMessage) {
      stopTask();
    } else if (message is String) {
      // Send UDP Message
    }
  }
}

class TcpTask extends LinkTask {
  Socket? tcpSocket;
  final MavlinkProtocol mavlink = MavlinkProtocol();
  final Logger logger = Logger();

  String hostName = '';
  int    portNum = 0;  

  TcpTask(ReceivePort receivePort) : super(receivePort);

  @override
  void startTask(String host, int port) async {
    hostName = host;
    portNum = port;

    tcpSocket = await Socket.connect(host, port);
    tcpSocket!.listen(
      (List<int> data) {
        Uint8List converted = Uint8List.fromList(data);
        mavlink.parser.parse(converted);
      },
      onDone: () {
        logger.i('TCP Socket Closed');
      },
      onError: (error) {
        logger.e('TCP Socket Error : $error');
      },
      cancelOnError: true
    );

    logger.i('start tcp task');
  }

  @override
  String getProtocol() => tcpProtocol;

  @override
  String getHost() => hostName;

  @override
  int getPortNum() => portNum;

  @override
  ReceivePort getMessagePort() => receivePort;

  @override
  void stopTask() {
    tcpSocket!.close();
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectTCPMessage) {
      stopTask();
    } else if (message is String) {
      // Send TCP Packet
    }
  }
}