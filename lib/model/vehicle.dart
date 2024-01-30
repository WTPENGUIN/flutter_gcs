import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/types.dart';

class Vehicle {
  // 기체 정보
  int          vehicleId = 0;
  MavType      vehicleType = mavTypeGeneric;
  MavAutopilot autopilotType = mavAutopilotGeneric;

  // GlobalPositionInt
  double latitude = 0.0;
  double longitude = 0.0;
  int relativeAltitude = 0;

  // Attitude
  float roll = 0.0;
  float pitch = 0.0;
  float yaw = 0.0;

  // 생성자
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    vehicleId = id;
    vehicleType = type;
    autopilotType = autoType;
  }
}