import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:peachgs_flutter/screens/main_root_page.dart';
import 'package:peachgs_flutter/screens/cal_page_desktop.dart';
import 'package:peachgs_flutter/screens/cal_page_mobile.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const MainRootWindow(),
    ),
    GoRoute(
      path: '/cal',
      name: 'calibration',
      builder: (context, state) => (Platform.isAndroid || Platform.isIOS) ? const VehicleCalMobile() : const VehicleCalDesktop(),
    ),
  ]
);