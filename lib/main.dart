import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:peachgs_flutter/router.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/utils/connection_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    // 네이버 맵 초기화
    if(Platform.isAndroid) {
      await dotenv.load(fileName: '.env');
      await NaverMapSdk.instance.initialize(
        clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
        onAuthFailed: (ex) {
          Logger logger = Logger();
          logger.e("********* 네이버맵 인증오류 : $ex *********");
        }
      );
    }
  }

  if(Platform.isWindows) {
    await windowManager.ensureInitialized();
    
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setSize(const Size(1200, 750));
      await windowManager.setMinimumSize(const Size(1200, 750));
      await windowManager.setSkipTaskbar(false);
      await windowManager.center();
      await windowManager.show();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MultiVehicle()),
        ChangeNotifierProvider(create: (_) => ConnectionManager())
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'NanumGothic'),
        themeMode: ThemeMode.system,
      ),
    )
  );
}