import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page.dart';
import 'package:peachgs_flutter/screens/video_page.dart';
import 'package:peachgs_flutter/widget/floating_buttons.dart';
import 'package:peachgs_flutter/widget/toolbar.dart';
import 'package:peachgs_flutter/widget/vehicle_info.dart';
import 'package:peachgs_flutter/widget/tool_buttons.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const ToolBar(),
      floatingActionButton: const FloatingButtons(),
      body: SafeArea(
        child: Stack(
          children: [
            const MapWindow(),
            if(Platform.isAndroid)
            Positioned(
              bottom: screenSize.height * 0.15,
              right: 0,
              child: const VideoPage()
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VehicleInfo()
            ),
            Positioned(
              bottom: screenSize.height * 0.075,
              left: screenSize.width * 0.01,
              right: 0,
              child: const ToolButtons()
            )
          ],
        )
      ),
    );
  }
}