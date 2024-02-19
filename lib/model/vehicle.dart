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

const double mathEpsilon = 4.94065645841247E-324;
const double mathPI      = 3.1415926535897932;
const uint16_t uint16max = 65535;

class Vehicle {
  Logger logger = Logger();

  // Vehicle basic information
  int          vehicleId     = 0;
  MavType      vehicleType   = mavTypeGeneric;
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
  int    vehicleHeading = 0;

  // Trajectory Point in vehicle
  List<LatLng> trajectoryList = [];

  // Home Position
  double homeLat = 0.0;
  double homeLon = 0.0;
  double homeAlt = 0.0;

  // distance to home
  double distanceToHome = 0.0;
  
  // Attitude
  double roll = 0.0;
  double pitch = 0.0;
  double yaw = 0.0;

  // GPS_Raw_Int(HDOP, VDOP)
  double altitudeMSL = double.nan;
  double eph = 0; // HDOP
  double epv = 0; // VDOP
  int satVisible = 0;
  GpsFixType gpsfixType = gpsFixTypeNoGps;
  String gpsfixTypeString = '';

  // VRF_HUD
  double climbRate = 0.0;
  double groundSpeed = 0.0;

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

  // RTL 명령어
  void vehicleRTL() {
    switch (autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("RTL");
        break;
      case mavAutopilotPx4:
        _px4SetFlightMode("Return");
        break;
      default:
        // TODO : 미지원 펌웨어 이륙 명령어 예외 처리
    }     
  }

  // 비행모드 전환 명령 내리기
  void setFlightMode(String flightMode) {
    switch (autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode(flightMode);
        break;
      case mavAutopilotPx4:
        _px4SetFlightMode(flightMode);
        break;
      default:
        // TODO : 미지원 펌웨어 비행모드 전환 명령어 예외 처리
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

  void _updateArmed(bool newArmed) {
    if(armed != newArmed) {
      armed = newArmed;

      // 시동 꺼짐 -> 시동 상태로 변경 되면 새로운 이동 경로를 그리기 위해 리스트 초기화
      if(armed) {
        trajectoryList.clear();
      }
    }
  }

  void _handleHeartBeat(MavlinkFrame frame) {
    var heartbeat = frame.message as Heartbeat;

    baseMode = heartbeat.baseMode;
    customMode = heartbeat.customMode;

    // 하트비트에서 시동 여부 추출
    bool newArmed = (heartbeat.baseMode & mavModeFlagDecodePositionSafety) == 0 ? false : true;
    _updateArmed(newArmed);
    
    // 하트비트에서 비행 모드 추출
    flightMode = getFlightModes(baseMode, customMode);

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

    // 시동 상태일 때, 이동 경로 포인트에 추가
    if(armed) {
      LatLng curPoint = LatLng(vehicleLat, vehicleLon);

      // 처음 시동이 걸린 상태면, 리스트에 추가
      if(trajectoryList.isEmpty) {
        trajectoryList.add(curPoint);
        trajectoryList.add(curPoint); // 네이버 맵에서 경로를 초기화해주기 위한 트릭
      } else {
        var distancePrevious = const Distance().as(
          LengthUnit.Meter,
          curPoint,
          trajectoryList.last
        );

        // 성능을 위해, 1m 이상으로 움직였을 때 포인트에 추가
        if(distancePrevious > 1.0) {
          trajectoryList.add(curPoint);
        }
      }
    }

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

  float _limitAngleToPMPIf(double angle) {
    if(angle > (-20 * mathPI) && angle < (20 * mathPI)) {
      while(angle > (mathPI + mathEpsilon)) {
        angle -= 2.0 * mathPI;
      }

      while(angle <= -(mathPI + mathEpsilon)) {
        angle += 2.0 + mathPI;
      }
    } else {
      // 근사치 계산
      angle = angle % mathPI;
    }

    return angle;
  }

  double _radianToDegrees(double radians) {
    return radians * (180.0 / mathPI);
  }

  void _handleAttitude(MavlinkFrame frame) {
    var attitude = frame.message as Attitude;

    double rollCal, pitchCal, yawCal;

    rollCal  = _limitAngleToPMPIf(attitude.roll);
    pitchCal = _limitAngleToPMPIf(attitude.pitch);
    yawCal   = _limitAngleToPMPIf(attitude.yaw);

    rollCal  = _radianToDegrees(rollCal);
    pitchCal = _radianToDegrees(pitchCal);
    yawCal   = _radianToDegrees(yawCal);

    if(yawCal < 0.0) {
      yawCal += 360.0;
    }

    roll  = rollCal;
    pitch = pitchCal;
    yaw   = yawCal;
    vehicleHeading = yawCal.truncate(); // 정수로 자르기(360도를 0도로 표시하기 위해)
  }

  void _handleGpsRawInt(MavlinkFrame frame) {
    var gpsrawint = frame.message as GpsRawInt;

    eph = (gpsrawint.eph == uint16max ? double.nan : (gpsrawint.eph / 100.0));
    epv = (gpsrawint.epv == uint16max ? double.nan : (gpsrawint.epv / 100.0));
    satVisible = gpsrawint.satellitesVisible;

    gpsfixType = gpsrawint.fixType;
    switch (gpsfixType) {
      case gpsFixTypeNoFix:
        gpsfixTypeString = "Not Fixed";
        break;
      case gpsFixType2dFix:
        gpsfixTypeString = "2D Fix";
        break;
      case gpsFixType3dFix:
        gpsfixTypeString = "3D Fix";
        break;
      case gpsFixTypeDgps:
        gpsfixTypeString = "DGPS";
        break;
      case gpsFixTypeRtkFloat:
        gpsfixTypeString = "RTK Float";
        break;
      case gpsFixTypeRtkFixed:
        gpsfixTypeString = "RTK Fix";
        break;   
      default:
        gpsfixTypeString = "-";
    }

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