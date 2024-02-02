import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/types.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/model/autopilot_flight_mode.dart';

const uint16_t uint16max = 65535;

class Vehicle {
  Logger logger = Logger();

  // 기체 정보
  int          vehicleId = 0;
  MavType      vehicleType = mavTypeGeneric;
  MavAutopilot autopilotType = mavAutopilotGeneric;

  // heartbeat
  uint8_t  baseMode = 0;
  uint32_t customMode = 0;
  String   flightMode = '';

  // GlobalPositionInt
  double latitude = 0.0;
  double longitude = 0.0;
  double relativeAltitude = 0.0;
  double hdg = 0.0;

  // Attitude
  float roll = 0.0;
  float pitch = 0.0;
  float yaw = 0.0;

  // GPSRawInt(HDOP, VDOP)
  double eph = 0; // HDOP
  double epv = 0; // VDOP
  GpsFixType gpsfixType = gpsFixTypeNoGps;

  // VRF_HUD
  float climbRate = 0.0;
  float groundSpeed = 0.0;

  // 생성자
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    vehicleId = id;
    vehicleType = type;
    autopilotType = autoType;
  }

  String flightModes(uint8_t baseMode, uint32_t customMode) {
    String flightMode = 'Unknown';

    bool flag = (baseMode & mavModeFlagCustomModeEnabled) == 0 ? false : true;
    if(flag) {
      if(autopilotType == mavAutopilotArdupilotmega) {
        flightMode = apmGetFlightModeName(customMode);
      } else { // PX4
        flightMode = px4GetFlightModeName(customMode);
      }
    }

    return flightMode;
  }

  // Mavlink 처리
  void mavlinkParsing(MavlinkFrame frame) {
    switch (frame.message.runtimeType) {
    case Heartbeat:
      var heartbeat = frame.message as Heartbeat;
      baseMode = heartbeat.baseMode;
      customMode = heartbeat.customMode;
      flightMode = flightModes(baseMode, customMode);
      break;
    case GlobalPositionInt:
      var positionInt = frame.message as GlobalPositionInt;
      latitude = (positionInt.lat / 10e6);
      longitude = (positionInt.lon / 10e6);
      relativeAltitude = (positionInt.relativeAlt / 1000.0);
      hdg = (positionInt.hdg / 100.0);
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
      gpsfixType = gpsrawint.fixType;
      break;
    case VfrHud:
      var vfrhud = frame.message as VfrHud;
      climbRate = vfrhud.climb;
      groundSpeed = vfrhud.groundspeed;
      break;
    default:
      break;
    }
  }
}