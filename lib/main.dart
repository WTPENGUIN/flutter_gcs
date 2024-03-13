import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:peachgs_flutter/router.dart';
import 'package:peachgs_flutter/model/app_setting.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/service/connection/connection_manager.dart';

// 위치 권한 요청
Future<bool> _getPermission() async {
  // 어플리케이션에 위치 권한이 허용 되었는지 확인
  var requestLocationStatus = await Permission.location.request();
  var locationStatus        = await Permission.location.status;

  // 허용이 되어 있지 않으면, openAppSettings 함수를 호출하여 권한 획득.
  if(requestLocationStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied) {
    openAppSettings();
  } else if(locationStatus.isRestricted) {
    openAppSettings();
  }

  // 위치 권한이 부여 되었는지 다시 확인
  var confirmLocationState = await Permission.location.status;

  // 허용이 되어 있지 않으면, 종료
  if(!confirmLocationState.isGranted) {
    return false;
  }

  return true;
}

// 모바일 환경 App 초기화
Future<bool> _initAppMobile() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  
  // 위치 권한 요청(권한 거부 당하면 앱 종료)
  bool isGranted = await _getPermission();
  if(!isGranted) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  // 네이버 맵 초기화를 위한 환경 파일 읽기
  await dotenv.load(fileName: '.env');

  // 네이버 맵 플러그인 초기화
  await NaverMapSdk.instance.initialize(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
    onAuthFailed: (ex) {
      Logger logger = Logger();
      logger.e("********* 네이버맵 인증오류 : $ex *********");
      
      return false;
    }
  );

  return true;
}

// 데스크톱 환경 App 초기화
Future<bool> _initAppDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();

  await windowManager.setSize(const Size(1200, 750));
  await windowManager.setMinimumSize(const Size(1200, 750));
  await windowManager.setSkipTaskbar(false);
  await windowManager.center();
  await windowManager.show();

  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // 모바일 실행 환경 어플리케이션 초기화
  if(Platform.isAndroid || Platform.isIOS) {
    bool init = await _initAppMobile();
    if(!init) {
      Logger logger = Logger();
      logger.e("앱 초기화 실패");

      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  // 데스크톱 실행 환경 어플리케이션 초기화
  if(Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await _initAppDesktop();
  }

  // 어플리케이션 세팅 초기화
  await AppSetting().loadAppConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MultiVehicle()),
        ChangeNotifierProvider(create: (_) => ConnectionManager()),
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