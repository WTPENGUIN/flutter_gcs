import 'dart:isolate';

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