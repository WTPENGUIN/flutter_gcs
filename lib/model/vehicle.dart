import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/types.dart';

const uint16_t uint16max = 65535;

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

  // GPSRawInt(HDOP, VDOP)
  double eph = 0; // HDOP
  double epv = 0; // VDOP

  // 생성자
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    vehicleId = id;
    vehicleType = type;
    autopilotType = autoType;
  }

  // Mavlink 처리
  void mavlinkParsing(MavlinkFrame frame) {
    switch (frame.message.runtimeType) {
    case GlobalPositionInt:
      var positionInt = frame.message as GlobalPositionInt;
      latitude = (positionInt.lat / 10e6);
      longitude = (positionInt.lon / 10e6);
      relativeAltitude = (positionInt.relativeAlt);
      break;
    case Attitude:
      var attitude = frame.message as Attitude;
      roll = attitude.roll;
      pitch = attitude.pitch;
      yaw = attitude.yaw;
      break;
    case GpsRawInt:
      var gpsrawint = frame.message as GpsRawInt;
      eph = (gpsrawint.eph == uint16max ? double.nan : (gpsrawint.eph / 100.0));
      epv = (gpsrawint.epv == uint16max ? double.nan : (gpsrawint.epv / 100.0));
      break;
    default:
      break;
    }
  }
}