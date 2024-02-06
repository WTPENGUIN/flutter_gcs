import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';
import 'package:peachgs_flutter/utils/tcp_connector.dart';
import 'package:peachgs_flutter/utils/udp_server_connector.dart';
import 'package:peachgs_flutter/utils/udp_client_connector.dart';

class LinkTaskManager extends ChangeNotifier {
  // 싱글톤 패턴
  LinkTaskManager._privateConstructor();
  static final LinkTaskManager _instance = LinkTaskManager._privateConstructor();
  factory LinkTaskManager() {
    return _instance;
  }
  
  final List<LinkTask> _taskList = [];
  final Logger logger = Logger();

  Future<void> startUDPServerTask(int port) async {
    UdpServerTask task = UdpServerTask(ReceivePort());

    _taskList.add(task);
    task.startTask('0.0.0.0', port);
  }

  Future<void> startUDPClientTask(String host, int port) async {
    UdpClientTask task = UdpClientTask(ReceivePort());

    _taskList.add(task);
    task.startTask(host, port);
  }  

  Future<void> startTCPTask(String host, int port) async {
    TcpTask task = TcpTask(ReceivePort());

    _taskList.add(task);
    task.startTask(host, port);
  }

  void stopUDPServerTask(String host, int port) {
    LinkTask? removedTask;

    for(var task in _taskList) {
      if(task.getProtocol() != udpServerProtocol) continue;

      if(task.getHost() == host && task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectUDPServerMessage);
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

  void stopUDPClientTask(String host, int port) {
    LinkTask? removedTask;

    for(var task in _taskList) {
      if(task.getProtocol() != udpClientProtocol) continue;

      if(task.getHost() == host && task.getPortNum() == port) {
        task.receivePort.sendPort.send(disconnectUDPClientMessage);
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
      } else if(task.getProtocol() == udpServerProtocol) {
        task.receivePort.sendPort.send(disconnectUDPServerMessage);
      } else if(task.getProtocol() == udpClientProtocol) {
        task.receivePort.sendPort.send(disconnectUDPClientMessage);
      }
    }

    _taskList.clear();
  }

  List<ReceivePort> getAllTaskPort() {
    List<ReceivePort> list = [];

    for(var currentTask in _taskList) {
      list.add(currentTask.receivePort);
    }

    return list;
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