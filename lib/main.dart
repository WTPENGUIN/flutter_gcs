import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/utils/link_manage.dart';
import 'package:peachgs_flutter/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  if(Platform.isWindows) {
    await windowManager.ensureInitialized();
    
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setSize(const Size(950, 750));
      await windowManager.setMinimumSize(const Size(950, 750));
      await windowManager.setSkipTaskbar(false);
      await windowManager.center();
      await windowManager.show();
    });
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