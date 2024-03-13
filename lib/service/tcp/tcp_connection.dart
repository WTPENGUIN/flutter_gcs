import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink/mavlink_protocol.dart';
import 'package:peachgs_flutter/service/connection/connection_task.dart';

const String tcpProtocol          = 'tcp';
const String disconnectTCPMessage = 'TCPDIS';

class TcpTask extends LinkTask {
  TcpTask(ReceivePort receivePort) : super(receivePort);
  
  Socket? _tcpSocket;
  final MavlinkProtocol _mavlink = MavlinkProtocol();

  String _hostName = '';
  int    _portNum = 0;  

  @override
  void startTask(String host, int port) async {
    _hostName = host;
    _portNum = port;

    _tcpSocket = await Socket.connect(host, port);
    _tcpSocket!.listen(
      (List<int> data) {
        Uint8List converted = Uint8List.fromList(data);
        _mavlink.parser.parse(converted);
      },
      onDone: () {
        Logger().i('TCP Socket Closed');
      },
      onError: (error) {
        Logger().e('TCP Socket Error : $error');
      },
      cancelOnError: true
    );

    receivePort.listen((dynamic message) {
      processMessage(message);
    });

    Logger().i('start tcp task');
  }

  @override
  String getProtocol() => tcpProtocol;

  @override
  String getHost() => _hostName;

  @override
  int getPortNum() => _portNum;

  @override
  ReceivePort getMessagePort() => receivePort;

  @override
  void stopTask() {
    if(_tcpSocket != null) {
      _tcpSocket!.close();
      _tcpSocket!.destroy();
      Logger().i('stop tcp task');
    }
  }

  @override
  void processMessage(dynamic message) {
    if(message == disconnectTCPMessage) {
      stopTask();
    } else if(message.runtimeType == MavlinkFrame) {
      MavlinkFrame frame = message as MavlinkFrame;
      _tcpSocket!.write(frame.serialize());
    } else {
      Logger().i(message);
    }
  }
}