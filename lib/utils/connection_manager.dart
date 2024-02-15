import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';
import 'package:peachgs_flutter/utils/tcp_connector.dart';
import 'package:peachgs_flutter/utils/udp_server_connector.dart';
import 'package:peachgs_flutter/utils/udp_client_connector.dart';

class ConnectionManager extends ChangeNotifier {
  // 싱글톤 패턴
  ConnectionManager._privateConstructor();
  static final ConnectionManager _instance = ConnectionManager._privateConstructor();
  factory ConnectionManager() {
    return _instance;
  }
  
  // Logger
  final Logger logger = Logger();

  // Task 리스트
  final List<LinkTask> _taskList = [];

  // UDP 서버(임무 컴퓨터에 연결) 태스크 시작
  Future<void> startUDPServerTask(int port) async {
    UdpServerTask task = UdpServerTask(ReceivePort());

    _taskList.add(task);
    task.startTask('0.0.0.0', port);
  }

  // UDP 클라이언트(GCS가 서버) 태스크 시작
  Future<void> startUDPClientTask(String host, int port) async {
    UdpClientTask task = UdpClientTask(ReceivePort());

    // 유효한 주소인지 검사
    if(!_isVaildHost(host)) return;

    _taskList.add(task);
    task.startTask(host, port);
  }  

  // TCP 태스크 시작
  Future<void> startTCPTask(String host, int port) async {
    TcpTask task = TcpTask(ReceivePort());

    // 유효한 주소인지 검사
    if(!_isVaildHost(host)) return;

    _taskList.add(task);
    task.startTask(host, port);
  }

  // UDP 서버(임무 컴퓨터에 연결) 태스크 정지
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

  // UDP 클라이언트(GCS가 서버) 태스크 시작
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

  // TCP 태스크 정지
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

  // 모든 태스크 정지
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

  // 태스크 데이터 전달용 포트 리스트 반환
  List<ReceivePort> _getAllTaskPort() {
    List<ReceivePort> list = [];

    for(var currentTask in _taskList) {
      list.add(currentTask.receivePort);
    }

    return list;
  }

  // 특정 링크의 데이터 전달용 포트 반환
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

  // 연결 링크에 메세지 쓰기
  void writeMessageLink(dynamic message) {
    if(_taskList.isEmpty) return;

    for(ReceivePort sendPort in _getAllTaskPort()) {
      sendPort.sendPort.send(message);
    }
  }

  // 입력된 IP 주소 유효성 검사
  bool _isVaildHost(String host) {
    InternetAddress? parsedAddress = InternetAddress.tryParse(host);

    if(parsedAddress != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    stopAllTask();
    super.dispose();
  }
}