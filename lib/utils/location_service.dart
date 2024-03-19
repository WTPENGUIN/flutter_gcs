import 'dart:core';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';

// 위치 정보 제공 클래스
class LocationService {
  // 싱글톤 패턴
  LocationService._privateConstructor();
  static final LocationService _instance = LocationService._privateConstructor();
  factory LocationService() {
    return _instance;
  }

  double _latitude  = double.nan;
  double _longitude = double.nan;

  double get latitude  => _latitude;
  double get longitude => _longitude;
  bool   isGetCoord    = false;

  // 유효한 위치인지 검사
  bool _isValidLocation(double lat, double lng) {
    bool vaildLat = (lat.isFinite && (lat.abs() <= 90));
    bool validLng = (lng.isFinite && (lng.abs() <= 180));

    return (vaildLat && validLng);
  }

  // 현재 내 위치 요청
  Future<bool> getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      _latitude  = pos.latitude;
      _longitude = pos.longitude;

      if(!_isValidLocation(_latitude, _longitude)) {
        throw Exception('Wrong Location');
      }
      
      isGetCoord = true;
      return true;
    } catch(e) {
      Logger().e('$_latitude, $_longitude');
      Logger().e(e.toString());
      return false;
    }
  }
}