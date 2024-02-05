import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:peachgs_flutter/model/vehicle.dart';

const int heartbeatMaxElpasedMSecs = 3500;

class MultiVehicle extends ChangeNotifier {
  // 싱글톤 패턴
  MultiVehicle._privateConstructor();
  static final MultiVehicle _instance = MultiVehicle._privateConstructor();
  factory MultiVehicle() {
    return _instance;
  }

  int _activeVehicle = 1;
  set setActiceId(int number) => _activeVehicle = number;
  int get getActiveId         => _activeVehicle;

  final List<Vehicle> _vehicles = [];

  // 타이머
  Timer? disconnectTimer;
  bool   _isTimerActive = false;

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
      if(tempVehicle.vehicleId == id) {
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
  void disconnectVehicle(int id) {
    Vehicle? removeVehicle = idSelectVehicle(id);

    if(removeVehicle == null) return;
    _vehicles.remove(removeVehicle);
    notifyListeners();
  }

  // 하트비트가 4초 이상 들어오지 않았을 시, 연결이 끊겼다고 가정하여 연결 해제
  void checkDisconnectedVehicle() {
    List<Vehicle> removeVehicles = [];
    for(Vehicle vehicle in _vehicles) {
      if(vehicle.heartbeatElapsedTimer.elapsedMilliseconds > heartbeatMaxElpasedMSecs) {
        removeVehicles.add(vehicle);
      }
    }

    for(Vehicle vehicle in removeVehicles) {
      disconnectVehicle(vehicle.vehicleId);
    }
  }

  void processHeartBeat(int id, Heartbeat msg) {
    // 이미 연결 된 system id는 무시, 동시 연결 기체 10대 제한
    if(idSelectVehicle(id) != null || _vehicles.length >= 10) return;
    
    MavType type = msg.type;
    MavAutopilot autopilot = msg.autopilot;

    // 고정익, 회전익만 허용
    if(type == mavTypeFixedWing || type == mavTypeQuadrotor || type == mavTypeHexarotor || type == mavTypeOctorotor || type == mavTypeGenericMultirotor || type == mavTypeDodecarotor) {
      if(_vehicles.isEmpty) {
        // TODO : 클래스 초기화때 타이머도 같이 초기화
        if(_isTimerActive == false) {
          disconnectTimer = Timer.periodic(const Duration(seconds: 4), (_) {
            checkDisconnectedVehicle();
          });
          _isTimerActive = true;
        }
        _activeVehicle = id; // 처음 연결된 기체를 액티브 기체로 설정
      }

      // 기체 추가
      Vehicle vehicle = Vehicle(id, type, autopilot);
      _vehicles.add(vehicle);
    }
  }

  // Mavlink 메세지 처리
  void mavlinkProcessing(MavlinkFrame frame) {
    if(frame.message.runtimeType == Heartbeat) {
      var heartbeat = frame.message as Heartbeat;
      processHeartBeat(frame.systemId, heartbeat);
    }

    // Mavlink 메세지 전송
    Vehicle? vehicle = idSelectVehicle(frame.systemId);
    if(vehicle == null) return;
    vehicle.mavlinkParsing(frame);

    notifyListeners();
  }

  @override
  void dispose() {
    if(disconnectTimer != null) disconnectTimer!.cancel();
    super.dispose();
  }
}