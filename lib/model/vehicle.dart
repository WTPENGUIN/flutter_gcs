import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/types.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:logger/logger.dart';
import 'package:peachgs_flutter/model/autopilot_flight_mode.dart';

const uint16_t uint16max = 65535;

class Vehicle {
  Logger logger = Logger();

  // Vehicle basic information
  int          vehicleId = 0;
  MavType      vehicleType = mavTypeGeneric;
  MavAutopilot autopilotType = mavAutopilotGeneric;

  // HeartBeat
  uint8_t  baseMode = 0;
  uint32_t customMode = 0;
  String   flightMode = '';
  bool     armed = false;

  // Global Position Int
  double vehicleLat = 0.0;
  double vehicleLon = 0.0;
  double vehicleRelativeAltitude = 0.0;
  double vehicleHeading = 0.0;

  // Home Position
  double homeLat = 0.0;
  double homeLon = 0.0;
  double homeAlt = 0.0;

  // Attitude
  float roll = 0.0;
  float pitch = 0.0;
  float yaw = 0.0;

  // GPS_Raw_Int(HDOP, VDOP)
  double eph = 0; // HDOP
  double epv = 0; // VDOP
  GpsFixType gpsfixType = gpsFixTypeNoGps;

  // VRF_HUD
  float climbRate = 0.0;
  float groundSpeed = 0.0;

  // Heartbeat timer
  final heartbeatElapsedTimer = Stopwatch();

  // Vehicle Constructor
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    vehicleId = id;
    vehicleType = type;
    autopilotType = autoType;
    heartbeatElapsedTimer.start(); // 하트비트 타이머 시작
  }

  // Get flight mode name
  String getFlightModes(uint8_t baseMode, uint32_t customMode) {
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

  // Mavlink Parsing
  void mavlinkParsing(MavlinkFrame frame) {
    switch (frame.message.runtimeType) {
    case Heartbeat:
      var heartbeat = frame.message as Heartbeat;
      baseMode = heartbeat.baseMode;
      customMode = heartbeat.customMode;
      flightMode = getFlightModes(baseMode, customMode);
      armed = (heartbeat.baseMode & mavModeFlagDecodePositionSafety) == 0 ? false : true;
      heartbeatElapsedTimer.reset(); // 하트비트 도착할 때마다 하트비트 타이머 리셋
      break;
    case GlobalPositionInt:
      var positionInt = frame.message as GlobalPositionInt;
      vehicleLat = (positionInt.lat / 10e6);
      vehicleLon = (positionInt.lon / 10e6);
      vehicleRelativeAltitude = (positionInt.relativeAlt / 1000.0);
      vehicleHeading = (positionInt.hdg / 100.0);
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
    case HomePosition:
      var homeposition = frame.message as HomePosition;
      homeLat = (homeposition.latitude  / 10e6);
      homeLon = (homeposition.longitude / 10e6);
      homeAlt = (homeposition.altitude  / 1000.0);
      break;
    default:
      break;
    }
  }
}