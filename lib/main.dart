import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:media_kit/media_kit.dart';
import 'package:peachgs_flutter/router.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/utils/connection_manager.dart';

// 위치 권한 요청
Future<bool> getPermission() async {
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
Future<bool> initAppMobile() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  
  // 위치 권한 요청(권한 거부 당하면 앱 종료)
  bool isGranted = await getPermission();
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
Future<bool> initAppDesktop() async {
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
  
  if(Platform.isAndroid || Platform.isIOS) {
    bool init = await initAppMobile();
    if(!init) {
      Logger logger = Logger();
      logger.e("앱 초기화 실패");

      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  if(Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await initAppDesktop();
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