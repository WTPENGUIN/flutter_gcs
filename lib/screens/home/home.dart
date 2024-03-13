import 'dart:io';
import 'package:flutter/material.dart';

import 'package:peachgs_flutter/screens/home/topbar.dart';
import 'package:peachgs_flutter/screens/flyview/desktop/flyview_desktop.dart';
import 'package:peachgs_flutter/screens/flyview/mobile/flyview_mobile.dart';
import 'package:peachgs_flutter/screens/video/video.dart';

class HomeWindow extends StatelessWidget {
  const HomeWindow({Key? key}) : super(key: key);

  // 실행 환경 체크
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
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.transparent,
                    child: const TopBar(),
                  )
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    color: Colors.transparent,
                    child: _isMobile() ? const FlyViewMobilePage() : const FlyViewDesktopPage(),
                  )
                ),
              ]
            ),
            const Positioned(
              bottom: 0,
              child: VideoPage()
            )
          ],
        ),
      ),
    );
  }
}
