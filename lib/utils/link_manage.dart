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
  // 싱글톤 패턴
  LinkTaskManager._privateConstructor();
  static final LinkTaskManager _instance = LinkTaskManager._privateConstructor();
  factory LinkTaskManager() {
    return _instance;
  }
  
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
    LinkTask? removedTask;

    for(var task in _taskList) {
      if(task.getProtocol() != udpProtocol) continue;

      if(task.getHost() == host && task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectUDPMessage);
        removedTask = task;
        break;
      }
    }

    if(removedTask == null) {
      return;
    } else {
      _taskList.remove(removedTask);
    }
  }

  void stopTCPTask(String host, int port) {
    LinkTask? removedTask;

    for(var task in _taskList) {
      if(task.getProtocol() != tcpProtocol) continue;

      if(task.getHost() == host && task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectTCPMessage);
        removedTask = task;
        break;
      }
    }

    if(removedTask == null) {
      return;
    } else {
      _taskList.remove(removedTask);
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

  ReceivePort? getTaskPort(String host, int port) {
    LinkTask? task;

    for(var currentTask in _taskList) {
      if(currentTask.getProtocol() != tcpProtocol) continue;

      if(currentTask.getHost() == host && currentTask.getPortNum() == port) {
        task = currentTask;
        break;
      }
    }
    
    if(task == null) {
      return null;
    } else {
      return task.receivePort;
    }
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
    if(udpSocket != null) {
      udpSocket!.close();
      logger.i('stop udp task');
    }
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectUDPMessage) {
      stopTask();
    } else {
      logger.i(message);
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

    receivePort.listen((dynamic message) {
      processMessage(message);
    });

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
    if(tcpSocket != null) {
      tcpSocket!.close();
      tcpSocket!.destroy();
      logger.i('stop tcp task');
    }
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectTCPMessage) {
      stopTask();
    } else {
      logger.i(message);
    }
  }
}