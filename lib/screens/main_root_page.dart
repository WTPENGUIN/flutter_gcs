import 'dart:io';
import 'package:flutter/material.dart';

import 'package:peachgs_flutter/widget/ui/top_bar.dart';
import 'package:peachgs_flutter/widget/component_widget/tool_button.dart';
import 'package:peachgs_flutter/widget/ui/vehicle_info.dart';
import 'package:peachgs_flutter/screens/map_page_desktop.dart';
import 'package:peachgs_flutter/screens/map_page_mobile.dart';
import 'package:peachgs_flutter/screens/video_page.dart';

class MainRootWindow extends StatefulWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  @override
  State<MainRootWindow> createState() => _MainRootWindowState();
}

class _MainRootWindowState extends State<MainRootWindow> {
  bool _isBottomShow = false;

  void _toggleBottomShow() {
    setState(() {
      _isBottomShow = !_isBottomShow;
    });
  }

  // 실행 환경이 모바일인지 반환
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
            // Builder를 통해 위젯을 빌드하면서, SafeArea를 제외한 앱의 전체 화면 크기를 얻음
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
                      flex: 10,
                      child: Container(
                        color: Colors.transparent,
                        child: _isMobile() ? const MapWindowMobile() : const MapWindowDesktop() // 도구 모음 버튼은 각 맵 페이지 안에 존재
                      )
                    )
                  ],
                ),
                // 비디오 위젯
                Positioned(
                  bottom: (_isBottomShow) ? ((appScreenSize.height / 11) * 2) : 0,
                  child: const VideoPage()
                ),
                // 기체 정보 위젯 숨기기 버튼
                Positioned(
                  bottom: (_isBottomShow) ? ((appScreenSize.height / 11) * 2.05) : 10,
                  right: 10,
                  child: ToolButton(
                    icon: (_isBottomShow) ? Icons.visibility_off : Icons.visibility,
                    submit: _toggleBottomShow,
                    color: Colors.blue,
                  )
                ),
                // 기체 정보 위젯
                Visibility(
                  visible: _isBottomShow,
                  child: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      // appScreenSize를 통해 Safearea를 제외한 앱의 높이를 얻음.
                      // Column으로 배치한 Expanded->flex 값이 각각 1,10이므로 화면을 11칸으로 나눈 것과 같음.
                      // 그래서 Container의 높이를 2칸을 차지하도록 컨테이너 높이를 설정
                      height: ((appScreenSize.height / 11) * 2),
                      color: Colors.transparent,
                      child: const VehicleInfo()
                    )
                  )
                ),
              ],
            );
          }
        )
      ),
    );
  }
}
