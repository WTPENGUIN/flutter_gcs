import 'package:flutter/material.dart';
import 'package:dart_mavlink/dialects/common.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:peachgs_flutter/model/vehicle.dart';

class MultiVehicle extends ChangeNotifier {
  // 싱글톤 패턴
  MultiVehicle._privateConstructor();

  static final MultiVehicle _instance = MultiVehicle._privateConstructor();
  
  factory MultiVehicle() {
    return _instance;
  }

  final List<Vehicle> _vehicles   = [];
  final List<int>     _vehiclesId = [];

  int countVehicle() {
    return _vehicles.length;
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

  // 하트비트 처리
  void processHeartBeat(MavlinkFrame frame) {
    var heartbeat = frame.message as Heartbeat;
    int id = frame.systemId;
    MavType type = heartbeat.type;
    MavAutopilot autopilot = heartbeat.autopilot;

    // 고정익, 회전익만 허용
    if(type == mavTypeFixedWing || type == mavTypeQuadrotor || type == mavTypeHexarotor || type == mavTypeOctorotor || type == mavTypeGenericMultirotor || type == mavTypeDodecarotor) {
      if(_vehicles.isEmpty) {
        Vehicle vehicle = Vehicle(id, type, autopilot);
        _vehiclesId.add(id);
        _vehicles.add(vehicle);
      } else {
        if(_vehiclesId.contains(id) || _vehicles.length >= 10) return; // 동일 번호의 기체가 있으면 연결 하지 않음(10대 이상 연결 허용 하지 않음)

        Vehicle vehicle = Vehicle(id, type, autopilot);
        _vehiclesId.add(id);
        _vehicles.add(vehicle);
      }
    }

    notifyListeners();
  }

  // 그 밖의 메세지 처리
  void processMavlink(MavlinkFrame frame) {
    Vehicle? vehicle = idSelectVehicle(frame.systemId);
    if(vehicle == null) {
      return;
    } else {
      vehicle.mavlinkParsing(frame);
      notifyListeners();
    }
  }
}