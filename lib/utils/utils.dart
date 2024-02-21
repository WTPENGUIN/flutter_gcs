import 'package:flutter/material.dart';

// 화면 크기에 따른 스케일러
double scaleSmallDevice(BuildContext context) {
  final size = MediaQuery.of(context).size;
  // For tiny devices.
  if (size.height < 600) {
    return 0.7;
  }
  // For normal devices.
  return 1.0;
}