import 'dart:async';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

import 'package:peachgs_flutter/model/app_setting.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/service/connection/connection_manager.dart';

class MavlinkProtocol {
  final MavlinkParser _mavlinkParser = MavlinkParser(MavlinkDialectArdupilotmega());
  final MultiVehicle  _multiVehicle = MultiVehicle();

  // 싱글톤 패턴(처음 생성 시, parser stream은 활성화 필요)
  static MavlinkProtocol? _instance;
  MavlinkProtocol._() {
    _mavlinkParser.stream.listen((MavlinkFrame frame) {
      _multiVehicle.mavlinkProcessing(frame);
    });

    _sendGCSHeartBeat();
  }
  factory MavlinkProtocol() => _instance ??= MavlinkProtocol._();
  MavlinkParser get parser => _mavlinkParser;

  // GCS의 시스템 ID 반환
  int getSystemId() {
    return AppSetting().id;
  }

  // GCS의 컴포넌트 ID 반환
  static int getComponentId() {
    return mavCompIdMissionplanner;
  }

  // GCS 하트비트 전송
  void _sendGCSHeartBeat() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      ConnectionManager link = ConnectionManager();

      var gcsHeartBeat = Heartbeat(
        customMode: 0,
        type: mavTypeGcs,
        autopilot: mavAutopilotInvalid,
        baseMode: mavModeManualArmed,
        systemStatus: mavStateActive,
        mavlinkVersion: 3
      );

      var mavlinkframe = MavlinkFrame.v2(0, getSystemId(), getComponentId(), gcsHeartBeat);
      link.writeMessageLink(mavlinkframe);
    });
  }
}