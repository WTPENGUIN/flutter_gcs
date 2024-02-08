import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_mavlink/types.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:peachgs_flutter/model/px4.dart';
import 'package:peachgs_flutter/model/ardupilot.dart';
import 'package:peachgs_flutter/utils/connection_manager.dart';
import 'package:peachgs_flutter/utils/mavlink_protocol.dart';

const uint16_t uint16max = 65535;

class Vehicle {
  Logger logger = Logger();

  // Vehicle basic information
  int          vehicleId = 0;
  MavType      vehicleType = mavTypeGeneric;
  MavAutopilot autopilotType = mavAutopilotGeneric;

  // HeartBeat
  uint8_t  baseMode   = 0;
  uint32_t customMode = 0;
  String   flightMode = '';
  bool     armed      = false;
  bool     isFlying   = false;

  // Global Position Int
  double vehicleLat = 0.0;
  double vehicleLon = 0.0;
  double vehicleRelativeAltitude = 0.0;
  double vehicleHeading = 0.0;

  // Home Position
  double homeLat = 0.0;
  double homeLon = 0.0;
  double homeAlt = 0.0;

  // distance to home
  double distanceToHome = 0.0;
  
  // Attitude
  float roll = 0.0;
  float pitch = 0.0;
  float yaw = 0.0;

  // GPS_Raw_Int(HDOP, VDOP)
  double altitudeMSL = double.nan;
  double eph = 0; // HDOP
  double epv = 0; // VDOP
  GpsFixType gpsfixType = gpsFixTypeNoGps;

  // VRF_HUD
  float climbRate = 0.0;
  float groundSpeed = 0.0;

  // Heartbeat 타이머
  final heartbeatElapsedTimer = Stopwatch();

  // Vehicle 생성자
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    vehicleId = id;
    vehicleType = type;
    autopilotType = autoType;
    heartbeatElapsedTimer.start(); // 하트비트 타이머 시작
  }

  // 현재 비행모드 파싱
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

  // 시동 명령어 전송
  void vehicleArm(bool armed) {
    ConnectionManager link = ConnectionManager();

    var command = CommandLong(
      param1: (armed) ? 1 : 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 0,
      param6: 0,
      param7: 0,
      command: mavCmdComponentArmDisarm,
      targetSystem: vehicleId,
      targetComponent: mavCompIdAll,
      confirmation: 0
    );
    
    var mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol.getSystemId(), MavlinkProtocol.getComponentId(), command);
    link.writeMessageLink(mavlinkFrame);
  }

  // 이륙 명령어
  void vehicleTakeOff(double alt) {
    // AMSL 고도가 잡히지 않으면(GPS 미수신) 이륙 거부
    if(altitudeMSL.isNaN) {
      // TODO : 이륙 거부 메세지
      return;
    }
    
    // 펌웨어에 따라 이륙 명령어 작성
    ConnectionManager link = ConnectionManager();
    switch (autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("GUIDED"); // 모드 변경
        vehicleArm(true);                  // 시동 걸기
        var command = CommandLong(
          param1: 0.0,
          param2: 0.0,
          param3: 0.0,
          param4: 0.0,
          param5: 0.0,
          param6: 0.0,
          param7: (alt > 10) ? alt : 10,
          command: mavCmdNavTakeoff,
          targetSystem: vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol.getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);     
        break;
      case mavAutopilotPx4:
        var command = CommandLong(
          param1: -1,
          param2: 0,
          param3: 0,
          param4: double.nan,
          param5: double.nan,
          param6: double.nan,
          param7: alt + altitudeMSL,
          command: mavCmdNavTakeoff,
          targetSystem: vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol.getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      default:
        // TODO : 미지원 펌웨어 이륙 명령어 예외 처리
    }    
  }

  // 착륙 명령어
  void vehicleLand() {
    switch (autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("LAND");
        break;
      case mavAutopilotPx4:
        _px4SetFlightMode("Land");
        break;
      default:
        // TODO : 미지원 펌웨어 이륙 명령어 예외 처리
    } 
  }

  // PX4 펌웨어 비행모드 전환 명령어
  void _px4SetFlightMode(String flightMode) {
    PX4FlightMode? mode = findPX4FlightMode(flightMode);

    if(mode == null) {
      logger.e('Unknown flight Mode : $flightMode');
      return;
    }

    uint8_t setBaseMode = mavModeFlagCustomModeEnabled;
    uint8_t newBaseMode = baseMode & ~mavModeFlagDecodePositionCustomMode;
    newBaseMode |= setBaseMode;
    
    // PX4 메인모드, 서브모드를 비트연산으로 커스텀 모드에 정보 담기
    Uint8List list = Uint8List(4)
      ..[3] = mode.subMode
      ..[2] = mode.mainMode
      ..[1] = 0
      ..[0] = 0;
    uint32_t newCustomMode = list.buffer.asByteData().getUint32(0, Endian.little);

    // PX4 not support MAV_CMD_DO_SET_MODE command
    var command = SetMode(
      customMode: newCustomMode,
      targetSystem: vehicleId,
      baseMode: newBaseMode
    );

    ConnectionManager link = ConnectionManager();
    MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol.getSystemId(), MavlinkProtocol.getComponentId(), command);
    link.writeMessageLink(mavlinkFrame);
  }

  // Ardupilot 펌웨어 비행모드 전환 명령어
  void _ardupilotSetFlightMode(String flightMode) {
    ArdupilotFlightMode? mode = findArduFlightMode(flightMode); // 전환 가능 모드 탐색

    if(mode == null) {
      logger.e('Unknown flight Mode : $flightMode');
      return;
    }

    uint8_t baseMode = mavModeFlagCustomModeEnabled;
    uint8_t customMode = mode.customMode;

    // Ardupilot support MAV_CMD_DO_SET_MODE command
    var command = CommandLong(
      param1: baseMode.toDouble(),
      param2: customMode.toDouble(),
      param3: 0.0,
      param4: 0.0,
      param5: 0.0,
      param6: 0.0,
      param7: 0.0,
      command: mavCmdDoSetMode,
      targetSystem: vehicleId,
      targetComponent: mavCompIdAll,
      confirmation: 0
    );

    ConnectionManager link = ConnectionManager();
    MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol.getSystemId(), MavlinkProtocol.getComponentId(), command);
    link.writeMessageLink(mavlinkFrame);
  }

  // 수신한 Mavlink 메세지 처리
  void mavlinkMessageReceived(MavlinkFrame frame) {
    switch (frame.message.runtimeType) {
    case Heartbeat:
      _handleHeartBeat(frame);
      break;
    case GlobalPositionInt:
      _handleGlobalPositionInt(frame);
      break;
    case Attitude:
      _handleAttitude(frame);
      break;
    case GpsRawInt:
      _handleGpsRawInt(frame);
      break;
    case VfrHud:
      _handleVfrHud(frame);
      break;
    case HomePosition:
      _handleHomePosition(frame);
      break;
    case CommandAck:
      _handleCommandAck(frame);
      break;
    case ExtendedSysState:
    _handleExtendedSysState(frame);
      break;
    default:
      break;
    }
  }

  void _handleHeartBeat(MavlinkFrame frame) {
    var heartbeat = frame.message as Heartbeat;

    baseMode = heartbeat.baseMode;
    customMode = heartbeat.customMode;
    
    // 하트비트에서 비행 모드 추출
    flightMode = getFlightModes(baseMode, customMode);
    
    // 하트비트에서 시동 여부 추출
    armed = (heartbeat.baseMode & mavModeFlagDecodePositionSafety) == 0 ? false : true;

    // 기체가 비행 중인지 추출(Ardupilot만 해당)
    if(autopilotType == mavAutopilotArdupilotmega) {
      bool flying = false;

      if(armed) {
        flying = heartbeat.systemStatus == mavStateActive;

        if(!flying && isFlying) {
          flying = ((heartbeat.systemStatus == mavStateCritical) && (heartbeat.systemStatus == mavStateEmergency));
        } 
      }
      isFlying = flying;
    }
    
    // 하트비트 도착할 때마다 하트비트 타이머 리셋
    heartbeatElapsedTimer.reset(); 
  }

  void _handleGlobalPositionInt(MavlinkFrame frame) {
    var positionInt = frame.message as GlobalPositionInt;

    vehicleLat = (positionInt.lat == 0) ? 0.0 : (positionInt.lat / 1e7);
    vehicleLon = (positionInt.lon == 0) ? 0.0 : (positionInt.lon / 1e7);
    vehicleRelativeAltitude = (positionInt.relativeAlt / 1000.0);
    vehicleHeading = (positionInt.hdg / 100.0);

    // 홈과 현재 사이 거리 구하기
    if((vehicleLat != 0 && vehicleLon != 0) && (homeLat != 0 && homeLon != 0)) {
      const Distance distance = Distance();

      distanceToHome = distance.as(
        LengthUnit.Meter,
        LatLng(vehicleLat, vehicleLon),
        LatLng(homeLat, homeLon)
      );
    }
  }

  void _handleAttitude(MavlinkFrame frame) {
    var attitude = frame.message as Attitude;

    roll = attitude.roll;
    pitch = attitude.pitch;
    yaw = attitude.yaw;
  }

  void _handleGpsRawInt(MavlinkFrame frame) {
    var gpsrawint = frame.message as GpsRawInt;

    eph = (gpsrawint.eph == uint16max ? double.nan : (gpsrawint.eph / 100.0));
    epv = (gpsrawint.epv == uint16max ? double.nan : (gpsrawint.epv / 100.0));
    gpsfixType = gpsrawint.fixType;

    if(gpsfixType >= gpsFixType3dFix) {
      altitudeMSL = gpsrawint.alt / 1000.0;
    }
  }

  void _handleVfrHud(MavlinkFrame frame) {
    var vfrhud = frame.message as VfrHud;
    
    climbRate = vfrhud.climb;
    groundSpeed = vfrhud.groundspeed;
  }

  void _handleHomePosition(MavlinkFrame frame) {
    var homeposition = frame.message as HomePosition;

    homeLat = (homeposition.latitude  / 1e7);
    homeLon = (homeposition.longitude / 1e7);
    homeAlt = (homeposition.altitude  / 1000.0);
  }

  void _handleCommandAck(MavlinkFrame frame) {
    //var commandack = frame.message as CommandAck;
  }

  void _handleExtendedSysState(MavlinkFrame frame) {
    var extendedSysState = frame.message as ExtendedSysState;

    switch (extendedSysState.landedState) {
      case mavLandedStateOnGround:
        isFlying = false;
        break;
      case mavLandedStateTakeoff:
      case mavLandedStateInAir:
        isFlying = true;
      case mavLandedStateLanding:
        isFlying = false;
      default:
        break;
    }
  }
}