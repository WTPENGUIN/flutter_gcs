import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:dart_mavlink/mavlink.dart';

import 'package:peachgs_flutter/utils/mavlink_protocol.dart';
import 'package:peachgs_flutter/utils/connection_task.dart';

const String tcpProtocol = 'tcp';
const String disconnectTCPMessage = 'TCPDIS';

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
    } else if(message.runtimeType == MavlinkFrame) {
      MavlinkFrame frame = message as MavlinkFrame;
      tcpSocket!.write(frame.serialize());
    } else {
      logger.i(message);
    }
  }
}