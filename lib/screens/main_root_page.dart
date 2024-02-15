import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page_desktop.dart';
import 'package:peachgs_flutter/screens/map_page_mobile.dart';
import 'package:peachgs_flutter/screens/video_page.dart';
import 'package:peachgs_flutter/widget/top_bar.dart';
import 'package:peachgs_flutter/widget/vehicle_info.dart';
import 'package:peachgs_flutter/widget/tool_buttons.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  bool _isMobile() {
    if(Platform.isAndroid || Platform.isIOS) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _isMobile() ? const MapWindowMobile() : const MapWindowDesktop(),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ToolBar()
            ),
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
            // TODO : 반응형 위치 구현
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