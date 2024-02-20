import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peachgs_flutter/widget/top_bar.dart';
import 'package:peachgs_flutter/screens/map_page_desktop.dart';
import 'package:peachgs_flutter/screens/map_page_mobile.dart';
import 'package:peachgs_flutter/widget/tool_buttons.dart';
import 'package:peachgs_flutter/widget/vehicle_info.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            // Builder를 통해 위젯을 빌드하면서, SafeArea를 제외한 앱의 전체 화면 크기를 가져옴
            Size appScreenSize = MediaQuery.of(context).size;
            
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.transparent,
                        child: const ToolBar()
                      )
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        color: Colors.transparent,
                        child: _isMobile() ? const MapWindowMobile() : const MapWindowDesktop()
                      )
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Colors.transparent,
                        child: const VehicleInfo()
                      )
                    )
                  ],
                ),
                Positioned(
                  // appScreenSize를 통해 Safearea를 제외한 앱의 높이를 얻음.
                  // Column으로 배치한 Expanded->flex 값이 각각 1,8,2이므로 화면을 11등분한 것과 같음.
                  bottom: ((appScreenSize.height / 11) * 2) - ((appScreenSize.height / 11) * 0.5),
                  left: 10,
                  child: const ToolButtons()
                )
              ],
            );
          }
        )
      ),
    );
  }
}