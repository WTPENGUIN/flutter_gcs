import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class MavlinkProtocol {
  final MavlinkParser _mavlinkParser = MavlinkParser(MavlinkDialectArdupilotmega());
  final MultiVehicle  _multiVehicle = MultiVehicle();

  // 싱글톤 패턴(처음 생성 시, parser stream은 활성화 필요)
  static MavlinkProtocol? _instance;
  MavlinkProtocol._() {
    _mavlinkParser.stream.listen((MavlinkFrame frame) {
      _multiVehicle.mavlinkProcessing(frame);
    });
  }
  factory MavlinkProtocol() => _instance ??= MavlinkProtocol._();

  // parser get 함수
  MavlinkParser get parser => _mavlinkParser;

  // GCS의 시스템 ID 반환
  // TODO : 사용자가 직접 설정 가능하게 변경
  int getSystemId() {
    return 200;
  }

  // GCS의 컴포넌트 ID 반환
  int getComponentId() {
    return mavCompIdMissionplanner;
  }
}