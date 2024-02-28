import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

import 'package:peachgs_flutter/model/vehicle.dart';

class MultiVehicle extends ChangeNotifier {
  // MultiVehicle 클래스는 싱글톤 클래스로 관리
  static MultiVehicle? _instance;
  MultiVehicle._privateConstructor() {
    _disconnectTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkDisconnectedVehicle(); // 1초마다 연결 끊어짐 감지 함수 호출
    });
  }
  factory MultiVehicle() => _instance ??= MultiVehicle._privateConstructor();

  int _activeVehicle = 1;
  set setActiceId(int number) => _activeVehicle = number;
  int get getActiveId         => _activeVehicle;

  // 3초 동안 하트비트가 없으면 연결이 끊어진 것으로 간주
  final int _disconnectTime = 3000;

  // 기체 목록 리스트
  final List<Vehicle> _vehicles = [];

  // 연결 끊어짐 감지 타이머
  Timer? _disconnectTimer;

  int countVehicle() {
    return _vehicles.length;
  }

  Vehicle? activeVehicle() {
    if(_vehicles.isEmpty) {
      return null;
    } else {
      return idSelectVehicle(_activeVehicle);
    }
  }

  Vehicle? idSelectVehicle(int id) {
    if(_vehicles.isEmpty) return null;

    for(Vehicle tempVehicle in _vehicles) {
      if(tempVehicle.id == id) {
        return tempVehicle;
      }
    }

    return null;
  }

  List<Vehicle> allVehicles() {
    List<Vehicle> vehicles = _vehicles;

    return vehicles;
  }

  // 기체 연결 해제
  void _disconnectVehicle(int id) {
    Vehicle? removeVehicle = idSelectVehicle(id);

    if(removeVehicle == null) return;
    _vehicles.remove(removeVehicle);
    notifyListeners();
  }

  // 연결 끊어진 기체 탐색
  void _checkDisconnectedVehicle() {
    List<Vehicle> removeVehicles = [];
    for(Vehicle vehicle in _vehicles) {
      if(vehicle.heartbeatTimer.elapsedMilliseconds > _disconnectTime) {
        removeVehicles.add(vehicle);
      }
    }

    for(Vehicle vehicle in removeVehicles) {
      _disconnectVehicle(vehicle.id);
    }
  }

  // 기체 추가
  void _addVehicle(int id, Heartbeat msg) {
    MavType type = msg.type;
    MavAutopilot autopilot = msg.autopilot;

    // 고정익, 회전익만 허용
    if(type == mavTypeFixedWing || type == mavTypeQuadrotor || type == mavTypeHexarotor || type == mavTypeOctorotor || type == mavTypeGenericMultirotor || type == mavTypeDodecarotor) {
      if(_vehicles.isEmpty) {
        _activeVehicle = id; // 처음 연결된 기체를 액티브 기체로 설정
      }

      // 기체 추가
      Vehicle vehicle = Vehicle(id, type, autopilot);
      _vehicles.add(vehicle);
    }
  }

  // 수신한 Mavlink 패킷 처리
  void mavlinkProcessing(MavlinkFrame frame) {
    if(frame.message.runtimeType == Heartbeat) {
      var heartbeat = frame.message as Heartbeat;
      
      // 이미 연결 된 system id는 무시, 동시 연결 기체 10대 제한
      if(idSelectVehicle(frame.systemId) == null && _vehicles.length <= 10) {
        _addVehicle(frame.systemId, heartbeat);
      }
    }

    switch (frame.message.runtimeType) {
      case Heartbeat:
      case GlobalPositionInt:
      case Attitude:
      case GpsRawInt:
      case VfrHud:
      case HomePosition:
      case CommandAck:
      case ExtendedSysState:
      case Statustext:
        Vehicle? vehicle = idSelectVehicle(frame.systemId);
        if(vehicle != null) {
          vehicle.mavlinkMessageReceived(frame);
          notifyListeners();
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    if(_disconnectTimer != null) _disconnectTimer!.cancel();
    super.dispose();
  }
}