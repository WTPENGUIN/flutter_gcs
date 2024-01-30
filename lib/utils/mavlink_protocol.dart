import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:peachgs_flutter/model/multivehicle.dart';
import 'package:logger/logger.dart';

class MavlinkProtocol {
  final MavlinkParser _mavlinkParser = MavlinkParser(MavlinkDialectCommon());
  final MultiVehicle  _multiVehicle = MultiVehicle();
  final Logger logger = Logger();

  // 싱글톤 패턴(처음 생성 시, parser stream은 활성화 필요)
  static MavlinkProtocol? _instance;

  MavlinkProtocol._() {
    _mavlinkParser.stream.listen((MavlinkFrame frm) {
      _mavlinkParsing(frm);
    });
  }

  factory MavlinkProtocol() => _instance ??= MavlinkProtocol._();

  // parser get 함수
  MavlinkParser get parser => _mavlinkParser;

  void _mavlinkParsing(MavlinkFrame frame) {
    switch (frame.message.runtimeType) {
      case Heartbeat:
        _multiVehicle.processHeartBeat(frame);
        break;
      default:
        _multiVehicle.processMavlink(frame);
        break;
    }
  }  
}