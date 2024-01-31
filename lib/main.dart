import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/utils/link_manage.dart';
import 'package:peachgs_flutter/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MultiVehicle()),
        ChangeNotifierProvider(create: (_) => LinkTaskManager())
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    )
  );
}