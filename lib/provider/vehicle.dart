import 'dart:async';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:dart_mavlink/types.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

import 'package:peachgs_flutter/provider/firmware/px4.dart';
import 'package:peachgs_flutter/provider/firmware/ardupilot.dart';
import 'package:peachgs_flutter/service/connection/connection_manager.dart';
import 'package:peachgs_flutter/utils/mavlink/mavlink_protocol.dart';

const double   mathEpsilon = 4.94065645841247E-324;
const double   mathPI      = 3.1415926535897932;
const uint16_t uint16max   = 65535;

class Vehicle {
  // 기체의 기본 정보
  int          _vehicleId     = 0;
  MavType      _vehicleType   = mavTypeGeneric;
  MavAutopilot _autopilotType = mavAutopilotGeneric;

  int          get id       => _vehicleId;
  MavType      get type     => _vehicleType;
  MavAutopilot get firmware => _autopilotType;

  // HeartBeat 메세지 정보
  uint8_t  _baseMode   = 0;
  uint32_t _customMode = 0;
  String   _flightMode = '';
  bool     _armed      = false;
  bool     _isFlying   = false;

  String get mode  => _flightMode;
  bool   get armed => _armed;
  bool   get isFly => _isFlying;

  // Global_Position_Int 메세지 정보
  double _vehicleLat = 0.0;
  double _vehicleLon = 0.0;
  double _vehicleRelativeAltitude = 0.0;
  int    _vehicleHeading = 0;

  double get lat     => _vehicleLat;
  double get lon     => _vehicleLon;
  double get alt     => _vehicleRelativeAltitude;
  int    get heading => _vehicleHeading;

  // 기체의 이동 경로 리스트
  final List<LatLng> _trajectoryList = [];
  List<LatLng> get route => _trajectoryList;

  // Home_Position 메세지 정보
  double _homeLat = 0.0;
  double _homeLon = 0.0;
  double _homeAlt = 0.0;

  double get hLat => _homeLat;
  double get hLon => _homeLon;
  double get hAlt => _homeAlt;

  // 이륙 위치에서 현재 기체 위치까지의 거리
  double _distanceToHome = 0.0;
  double get distanceHome => _distanceToHome;
  
  // Attitude 메세지 정보
  double _roll = 0.0;
  double _pitch = 0.0;
  double _yaw = 0.0;

  double get roll  => _roll;
  double get pitch => _pitch;
  double get yaw   => _yaw;

  // GPS_Raw_Int 메세지 정보
  double _eph = 0; // HDOP
  double _epv = 0; // VDOP
  double altitudeMSL = double.nan; // 해발고도
  int   _sattleVisible = 0;
  GpsFixType _gpsfixType = gpsFixTypeNoGps;
  String _gpsfixTypeString = '';

  double get hdop    => _eph;
  double get vdop    => _epv;
  int    get gpsSat  => _sattleVisible;
  String get fixType => _gpsfixTypeString;

  // Vrf_Hud 메세지 정보
  double _climbRate = 0.0;
  double _groundSpeed = 0.0;

  double get vSpeed => _climbRate;
  double get hSpeed => _groundSpeed;

  // StatusText 메세지 정보
  int _statusTextLastId = 0;
  int _statusTextLastChunkSeq = 0;
  final List<int> _statusChunkText = [];

  // 연결 끊어짐 감지 타이머
  // Heartbeat 메세지 수신 시, 타이머 시간 초기화
  final Stopwatch _heartbeatElapsedTimer = Stopwatch();
  Stopwatch get heartbeatTimer => _heartbeatElapsedTimer;

  // Vehicle 인스턴스 생성자
  Vehicle(int id, MavType type, MavAutopilot autoType) {
    _vehicleId = id;
    _vehicleType = type;
    _autopilotType = autoType;
    _heartbeatElapsedTimer.start(); // 연결 끊어짐 감지 타이머 시작ㄴ
  }

  // 현재 기체의 비행모드를 가져오는 함수
  String getFlightModes(uint8_t baseMode, uint32_t customMode) {
    String flightMode = 'Unknown';

    bool flag = (baseMode & mavModeFlagCustomModeEnabled) == 0 ? false : true;
    if(flag) {
      if(_autopilotType == mavAutopilotArdupilotmega) {
        flightMode = apmGetFlightModeName(customMode);
      } else {
        flightMode = px4GetFlightModeName(customMode);
      }
    }

    return flightMode;
  }

  // 기체에 시동 명령어 전송
  void arm(bool armed) {
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
      targetSystem: _vehicleId,
      targetComponent: mavCompIdAll,
      confirmation: 0
    );
    
    var mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
    link.writeMessageLink(mavlinkFrame);
  }

  // 기체에 이륙 명령어 전송
  void takeOff(double alt) {
    // AMSL 고도가 잡히지 않으면(GPS 미수신) 이륙 거부
    if(altitudeMSL.isNaN) {
      // TODO : 이륙 거부 메세지를 출력
      return;
    }
    
    // 펌웨어에 따라 이륙 명령어 작성
    ConnectionManager link = ConnectionManager();
    switch (_autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("GUIDED"); // 모드 변경
        arm(true);                         // 시동 걸기
        var command = CommandLong(
          param1: 0.0,
          param2: 0.0,
          param3: 0.0,
          param4: 0.0,
          param5: 0.0,
          param6: 0.0,
          param7: (alt > 10) ? alt : 10,
          command: mavCmdNavTakeoff,
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
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
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      default:
        // TODO : 미지원 펌웨어 이륙 명령어 예외 처리
    }    
  }

  // 기체에 착륙 명령어 전송
  void land() {
    switch (_autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("LAND");
        break;
      case mavAutopilotPx4:
        _px4SetFlightMode("Land");
        break;
      default:
        // TODO : 미지원 펌웨어 착륙 명령어 예외 처리
    } 
  }

  // 기체에 귀환 명령어 전송
  void rtl() {
    switch (_autopilotType) {
      case mavAutopilotArdupilotmega:
        _ardupilotSetFlightMode("RTL");
        break;
      case mavAutopilotPx4:
        _px4SetFlightMode("Return");
        break;
      default:
        // TODO : 미지원 펌웨어 귀환 명령어 예외 처리
    }     
  }

  // 기체에 고도 변환 명령어 전송
  void changeAltitude(double altitude) {
    switch (_autopilotType) {
      case mavAutopilotArdupilotmega:
        var command = SetPositionTargetLocalNed(
          timeBootMs: 0,
          x: 0.0,
          y: 0.0,
          z: -altitude,
          vx: 0.0,
          vy: 0.0,
          vz: 0.0,
          afx: 0.0,
          afy: 0.0,
          afz: 0.0,
          yaw: 0.0,
          yawRate: 0.0,
          typeMask: 65528, // type_mask = 0xFFF8, QGroundControl 코드 참조
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          coordinateFrame: mavFrameLocalOffsetNed
        );

        ConnectionManager link = ConnectionManager();
        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      case mavAutopilotPx4:
        double newAltRel = _vehicleRelativeAltitude + altitude;
        var command = CommandLong(
          param1: -1.0,
          param2: mavDoRepositionFlagsChangeMode.toDouble(),
          param3: 0.0,
          param4: double.nan,
          param5: double.nan,
          param6: double.nan,
          param7: _homeAlt + newAltRel,
          command: mavCmdDoReposition,
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        ConnectionManager link = ConnectionManager();
        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      default:
        // TODO : 미지원 펌웨어 고도 변환 명령어 예외 처리
    }
  }

  // 기체에 이동 명령어 전송
  void goto(LatLng location) {
    switch (_autopilotType) {
      case mavAutopilotArdupilotmega:
        var command = MissionItem(
          param1: 0,
          param2: 0,
          param3: 0,
          param4: 0,
          x: location.latitude,
          y: location.longitude,
          z: _vehicleRelativeAltitude,
          seq: 0,
          command: mavCmdNavWaypoint,
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          frame: mavFrameGlobalRelativeAlt,
          current: 2,
          autocontinue: 1,
          missionType: mavMissionTypeMission
        );

        ConnectionManager link = ConnectionManager();
        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      case mavAutopilotPx4:
        var command = CommandLong(
          param1: -1.0,
          param2: mavDoRepositionFlagsChangeMode.toDouble(),
          param3: 0.0,
          param4: double.nan,
          param5: location.latitude,
          param6: location.longitude,
          param7: altitudeMSL.toDouble(),
          command: mavCmdDoReposition,
          targetSystem: _vehicleId,
          targetComponent: mavCompIdAll,
          confirmation: 0
        );

        ConnectionManager link = ConnectionManager();
        MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
        link.writeMessageLink(mavlinkFrame);
        break;
      default:
        // TODO : 미지원 펌웨어 이동 명령어 예외 처리
    }
  }

  // 기체의 비행모드 전환
  void setMode(String flightMode) {
    switch (_autopilotType) {
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
      Logger().e('Unknown flight Mode : $flightMode');
      return;
    }

    uint8_t setBaseMode = mavModeFlagCustomModeEnabled;
    uint8_t newBaseMode = _baseMode & ~mavModeFlagDecodePositionCustomMode;
    newBaseMode |= setBaseMode;
    
    // PX4 메인모드, 서브모드를 비트연산으로 커스텀 모드에 정보 담기
    Uint8List list = Uint8List(4)
      ..[3] = mode.subMode
      ..[2] = mode.mainMode
      ..[1] = 0
      ..[0] = 0;
    uint32_t newCustomMode = list.buffer.asByteData().getUint32(0, Endian.little);

    // PX4에서는 MAV_CMD_DO_SET_MODE 명령어를 지원하지 않음
    // SET_MODE 명령어 대신 사용
    var command = SetMode(
      customMode: newCustomMode,
      targetSystem: _vehicleId,
      baseMode: newBaseMode
    );

    ConnectionManager link = ConnectionManager();
    MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
    link.writeMessageLink(mavlinkFrame);
  }

  // Ardupilot 펌웨어 비행모드 전환 명령어
  void _ardupilotSetFlightMode(String flightMode) {
    ArdupilotFlightMode? mode = findArduFlightMode(flightMode); // 전환 가능 모드 탐색

    if(mode == null) {
      Logger().e('Unknown flight Mode : $flightMode');
      return;
    }

    uint8_t baseMode = mavModeFlagCustomModeEnabled;
    uint8_t customMode = mode.customMode;

    // Ardupilot에서는 MAV_CMD_DO_SET_MODE 명령어를 지원
    var command = CommandLong(
      param1: baseMode.toDouble(),
      param2: customMode.toDouble(),
      param3: 0.0,
      param4: 0.0,
      param5: 0.0,
      param6: 0.0,
      param7: 0.0,
      command: mavCmdDoSetMode,
      targetSystem: _vehicleId,
      targetComponent: mavCompIdAll,
      confirmation: 0
    );

    ConnectionManager link = ConnectionManager();
    MavlinkFrame mavlinkFrame = MavlinkFrame.v2(0, MavlinkProtocol().getSystemId(), MavlinkProtocol.getComponentId(), command);
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
    case Statustext:
      _handleStatusText(frame);
      break;
    default:
      break;
    }
  }

  void _updateArmed(bool newArmed) {
    if(_armed != newArmed) {
      _armed = newArmed;

      // 시동 꺼짐 -> 시동 상태로 변경 되면 새로운 이동 경로를 그리기 위해 리스트 초기화
      if(_armed) {
        _trajectoryList.clear();
      }
    }
  }

  void _handleHeartBeat(MavlinkFrame frame) {
    var heartbeat = frame.message as Heartbeat;

    _baseMode = heartbeat.baseMode;
    _customMode = heartbeat.customMode;

    // HeartBeat 메세지에서 시동 여부 얻기
    bool newArmed = (heartbeat.baseMode & mavModeFlagDecodePositionSafety) == 0 ? false : true;
    _updateArmed(newArmed);
    
    // HeartBeat 메세지에서 비행 모드 얻기
    _flightMode = getFlightModes(_baseMode, _customMode);

    // 기체가 비행 중인지 감지(Ardupilot만 해당)
    if(_autopilotType == mavAutopilotArdupilotmega) {
      bool flying = false;

      if(_armed) {
        flying = heartbeat.systemStatus == mavStateActive;

        if(!flying && _isFlying) {
          flying = ((heartbeat.systemStatus == mavStateCritical) && (heartbeat.systemStatus == mavStateEmergency));
        } 
      }
      _isFlying = flying;
    }
    
    // Heartbeat 메세지 도착할 때마다 연결 끊어짐 감지 타이머 시간 초기화
    _heartbeatElapsedTimer.reset();
  }

  void _handleGlobalPositionInt(MavlinkFrame frame) {
    var positionInt = frame.message as GlobalPositionInt;

    _vehicleLat = (positionInt.lat == 0) ? 0.0 : (positionInt.lat / 1e7);
    _vehicleLon = (positionInt.lon == 0) ? 0.0 : (positionInt.lon / 1e7);
    _vehicleRelativeAltitude = (positionInt.relativeAlt / 1000.0);

    // 시동 상태일 때, 이동 경로 포인트에 추가
    if(_armed) {
      LatLng curPoint = LatLng(_vehicleLat, _vehicleLon);

      // 처음 시동이 걸린 상태면, 현재 위치를 리스트에 추가
      if(_trajectoryList.isEmpty) {
        _trajectoryList.add(curPoint);
        _trajectoryList.add(curPoint); // 네이버 맵에서 경로를 초기화해주기 위한 트릭
      } else {
        var distancePrevious = const Distance().as(
          LengthUnit.Meter,
          curPoint,
          _trajectoryList.last
        );

        // 성능을 위해, 1m 이상으로 움직였을 때 포인트에 추가
        if(distancePrevious > 1.0) {
          _trajectoryList.add(curPoint);
        }
      }
    }

    // 이륙 위치와 현재 기체 사이의 거리 구하기
    if((_vehicleLat != 0 && _vehicleLon != 0) && (_homeLat != 0 && _homeLon != 0)) {
      const Distance distance = Distance();

      _distanceToHome = distance.as(
        LengthUnit.Meter,
        LatLng(_vehicleLat, _vehicleLon),
        LatLng(_homeLat, _homeLon)
      );
    }
  }

  // 각도 범위 유지
  float _limitAngleToPMPIf(double angle) {
    if(angle > (-20 * mathPI) && angle < (20 * mathPI)) {
      while(angle > (mathPI + mathEpsilon)) {
        angle -= 2.0 * mathPI;
      }

      while(angle <= -(mathPI + mathEpsilon)) {
        angle += 2.0 + mathPI;
      }
    } else {
      angle = angle % mathPI;
    }

    return angle;
  }

  void _handleAttitude(MavlinkFrame frame) {
    var attitude = frame.message as Attitude;

    double rollCal, pitchCal, yawCal;

    // 각도 범위를 한정
    rollCal  = _limitAngleToPMPIf(attitude.roll);
    pitchCal = _limitAngleToPMPIf(attitude.pitch);
    yawCal   = _limitAngleToPMPIf(attitude.yaw);

    // 라디안을 각도로 변환
    rollCal  = rollCal  * (180.0 / mathPI);
    pitchCal = pitchCal * (180.0 / mathPI);
    yawCal   = yawCal   * (180.0 / mathPI);

    // yaw가 나타내는 범위 한정(0 ~ 360)
    if(yawCal < 0.0) {
      yawCal += 360.0;
    }

    _roll  = rollCal;
    _pitch = pitchCal;
    _yaw   = yawCal;
    _vehicleHeading = yawCal.truncate(); // 정수로 자르기(360도를 0도로 표시하기 위해)
  }

  void _handleGpsRawInt(MavlinkFrame frame) {
    var gpsrawint = frame.message as GpsRawInt;

    _eph = (gpsrawint.eph == uint16max ? double.nan : (gpsrawint.eph / 100.0));
    _epv = (gpsrawint.epv == uint16max ? double.nan : (gpsrawint.epv / 100.0));
    _sattleVisible = gpsrawint.satellitesVisible;

    _gpsfixType = gpsrawint.fixType;
    switch (_gpsfixType) {
      case gpsFixTypeNoFix:
        _gpsfixTypeString = "Not Fixed";
        break;
      case gpsFixType2dFix:
        _gpsfixTypeString = "2D Fix";
        break;
      case gpsFixType3dFix:
        _gpsfixTypeString = "3D Fix";
        break;
      case gpsFixTypeDgps:
        _gpsfixTypeString = "DGPS";
        break;
      case gpsFixTypeRtkFloat:
        _gpsfixTypeString = "RTK Float";
        break;
      case gpsFixTypeRtkFixed:
        _gpsfixTypeString = "RTK Fix";
        break;   
      default:
        _gpsfixTypeString = "-";
    }

    if(_gpsfixType >= gpsFixType3dFix) {
      altitudeMSL = gpsrawint.alt / 1000.0;
    }
  }

  void _handleVfrHud(MavlinkFrame frame) {
    var vfrhud = frame.message as VfrHud;
    
    _climbRate = vfrhud.climb;
    _groundSpeed = vfrhud.groundspeed;
  }

  void _handleHomePosition(MavlinkFrame frame) {
    var homeposition = frame.message as HomePosition;

    _homeLat = (homeposition.latitude  / 1e7);
    _homeLon = (homeposition.longitude / 1e7);
    _homeAlt = (homeposition.altitude  / 1000.0);
  }

  void _handleExtendedSysState(MavlinkFrame frame) {
    var extendedSysState = frame.message as ExtendedSysState;

    switch (extendedSysState.landedState) {
      case mavLandedStateOnGround:
        _isFlying = false;
        break;
      case mavLandedStateTakeoff:
      case mavLandedStateInAir:
        _isFlying = true;
      case mavLandedStateLanding:
        _isFlying = false;
      default:
        break;
    }
  }

  void _handleCommandAck(MavlinkFrame frame) {
    //var commandack = frame.message as CommandAck;
  }

  // TODO : 청크화 메세지 조립
  void _handleStatusText(MavlinkFrame frame) {
    var statusText = frame.message as Statustext;
    
    // 임시 리스트에 복사
    List<int> tempList = [];
    for(int ch in statusText.text) {
      if(ch <= 0) break;
      tempList.add(ch);
    }

    // status 메세지의 id로 청크화 되었는지 판단(0보다 크면 청크화)
    if(statusText.id != 0) {
      Timer(const Duration(seconds: 3), () {
        Logger().i('${statusText.severity} : ${String.fromCharCodes(_statusChunkText)}');
        
        // 청크 조립이 완료 되었으므로 초기화
        _statusTextLastId = 0;
        _statusTextLastChunkSeq = 0;
        _statusChunkText.clear();
      });

      if(statusText.id != _statusTextLastId) {
        _statusTextLastChunkSeq = 0;
        _statusTextLastId = statusText.id;
      }

      if(_statusTextLastChunkSeq + 1 < statusText.chunkSeq) {
        // 처음 청크나 마지막 청크 누락 상황
      }

      _statusTextLastChunkSeq = statusText.chunkSeq;
      _statusChunkText.addAll(tempList);

      // 마지막 청크인지 판단하여 출력
      if(_statusChunkText.length == statusText.text.length) {
        Logger().i('${statusText.severity} : ${String.fromCharCodes(_statusChunkText)}');
        
        // 청크 조립이 완료 되었으므로 초기화
        _statusTextLastId = 0;
        _statusTextLastChunkSeq = 0;
        _statusChunkText.clear();
      }
    } else {
      Logger().i('${statusText.severity} : ${String.fromCharCodes(tempList)}');
    }
  }
}