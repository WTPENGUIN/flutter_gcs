import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multivehicle.dart';
import 'package:peachgs_flutter/utils/linkmanager.dart';
import 'package:peachgs_flutter/screens/mainrootwindow.dart';

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
      child: const MaterialApp(
        home: MainRootWindow(),
        debugShowCheckedModeBanner: false,
      ),
    )
  );
}