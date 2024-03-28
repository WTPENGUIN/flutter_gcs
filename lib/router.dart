import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:peachgs_flutter/screens/home/main_page.dart';
import 'package:peachgs_flutter/screens/setting/setting_page.dart';
import 'package:peachgs_flutter/screens/calibration/desktop/calibration_desktop.dart';
import 'package:peachgs_flutter/screens/calibration/mobile/calibration_mobile.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const MainRootPage(),
    ),
    GoRoute(
      path: '/cal',
      builder: (context, state) => (Platform.isAndroid || Platform.isIOS) ? const CalibrationMobile() : const CalibrationDesktop(),
    ),
    GoRoute(
      path: '/setting',
      builder:(context, state) => const SettingPage(),
    )
  ]
);