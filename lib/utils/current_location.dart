import 'dart:core';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';

// CurrentLocation 클래스
class CurrentLocation {
  double latitude  = double.nan;
  double longitude = double.nan;

  Logger logger = Logger();

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

      latitude = pos.latitude;
      longitude = pos.longitude;

      if(!_isValidLocation(latitude, longitude)) {
        throw Exception('Wrong Location');
      }
      
      return true;
    } catch(e) {
      logger.e('$latitude, $longitude');
      logger.e(e.toString());
      return false;
    }
  }
}