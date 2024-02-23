import 'dart:core';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';

// Location 클래스
class Location {
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
  void getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      latitude = pos.latitude;
      longitude = pos.longitude;

      if(_isValidLocation(latitude, longitude)) {
        throw Exception('Wrong Location');
      }
    } catch(e) {
      logger.e(e.toString());
    }
  }
}