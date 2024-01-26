import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/utils/comm_utils.dart';
import 'package:peachgs_flutter/screens/map_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => CommUtils(),
      child: MainPage(),
    ),
  );
}