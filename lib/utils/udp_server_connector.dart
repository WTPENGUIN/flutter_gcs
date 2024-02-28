import 'dart:io';
import 'dart:isolate';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink_protocol.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';

String udpServerProtocol          = 'udpserver';
String disconnectUDPServerMessage = 'UDPSERVERDIS';

class _UdpClient {
  _UdpClient(this._address, this._port);

  final InternetAddress _address;
  InternetAddress get address => _address;

  final int _port;
  int get port => _port;
}

class UdpServerTask extends LinkTask {
  UdpServerTask(ReceivePort receivePort) : super(receivePort);

  RawDatagramSocket?    _udpSocket;
  final MavlinkProtocol _mavlink = MavlinkProtocol();

  String _hostName = '';
  int    _portNum = 0;

  final List<_UdpClient> _clients = [];

  @override
  void startTask(String host, int port) async {
    _hostName = host; // Not Used.
    _portNum = port;

    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _udpSocket!.listen((RawSocketEvent event) {
      if(event != RawSocketEvent.read) return;

      Datagram? frame = _udpSocket!.receive();
      if(frame == null) {
        return;
      } else {
        _mavlink.parser.parse(frame.data);

        // UDP 패킷에 새로운 주소와 포트번호가 있으면 리스트에 추가
        if(!_isContainList(frame.address, frame.port)) {
          _UdpClient client = _UdpClient(frame.address, frame.port);
          _clients.add(client);
        }
      }
    });

    receivePort.listen((dynamic message) {
      processMessage(message);
    });

    Logger().i('start udp task');
  }

  @override
  String getProtocol() => udpServerProtocol;

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
    if(message == disconnectUDPServerMessage) {
      stopTask();
    } else if(message.runtimeType == MavlinkFrame) {
      MavlinkFrame frame = message as MavlinkFrame;
      for(_UdpClient client in _clients) {
        _udpSocket!.send(frame.serialize(), client.address, client.port);
      }
    } else {
      Logger().i(message);
    }
  }

  // 해당 주소와 포트가 리스트에 있는지 검사
  bool _isContainList(InternetAddress address, int port) {
    for(_UdpClient client in _clients) {
      if(client.address == address && client.port == port) {
        return true;
      }
    }

    return false;
  }
}