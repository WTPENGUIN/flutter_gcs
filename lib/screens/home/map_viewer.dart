import 'dart:io';
import 'package:flutter/material.dart';

import 'package:peachgs_flutter/screens/flyview/desktop/flyview_desktop.dart';
import 'package:peachgs_flutter/screens/planview/desktop/planview_desktop.dart';
import 'package:peachgs_flutter/screens/flyview/mobile/flyview_mobile.dart';
import 'package:peachgs_flutter/screens/planview/mobile/planview_mobile.dart';
import 'package:peachgs_flutter/widget/common_widget/icon_string_button.dart';

class MapViewer extends StatefulWidget {
  const MapViewer({super.key});

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  //  실행 환경 체크
  bool _isMobile() {
    if(Platform.isAndroid || Platform.isIOS) {
      return true;
    } else {
      return false;
    }
  }
  
  // FlyView / PlanView 토글
  bool _isPlanView = false;
  void _toggleView() {
    setState(() {
      _isPlanView = !_isPlanView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(_isPlanView)  _isMobile() ? const PlanViewMobile() : const PlanViewDesktop(),
        if(!_isPlanView) _isMobile() ? const FlyViewMobile()  : const FlyViewDesktop(),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: IconStringButton(
              icon: Icons.edit_road,
              submit: _toggleView,
              color: Colors.black,
              title: _isPlanView ? "비행" : "계획",
            )
          )
        )
      ]
    );
  }
}