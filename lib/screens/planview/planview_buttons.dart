import 'package:flutter/material.dart';

import 'package:peachgs_flutter/colors.dart';
import 'package:peachgs_flutter/widget/common_widget/icon_string_button.dart';

class PlanViewButtons extends StatefulWidget {
  const PlanViewButtons({
    Key? key,
    this.takeOffPressed,
    this.wayPointState,
    this.wayPointPressed,
    this.rtlPressed,
    this.mapCenterPressed
  }) : super(key: key);

  final Function()? takeOffPressed;
  final bool?       wayPointState;
  final Function()? wayPointPressed;
  final Function()? rtlPressed;
  final Function()? mapCenterPressed;

  @override
  State<PlanViewButtons> createState() => _PlanViewButtonsState();
}

class _PlanViewButtonsState extends State<PlanViewButtons> {
  bool _isOpen = true; // 도구 모음 열림 상태

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // 이륙 명령어 버튼
  Widget _takeOffCommandButton() {
    return Visibility(
      visible: _isOpen,
      child: IconStringButton(
        icon: Icons.file_upload,
        color: pPeach,
        submit: widget.takeOffPressed,
        title: '이륙'
      )
    );
  }

  // 웨이포인트 추가 버튼
  Widget _wayPointButton() {
    return Visibility(
      visible: _isOpen && (widget.wayPointState != null),
        child: IconStringButton(
        icon: Icons.control_point,
        color: (widget.wayPointState != null && widget.wayPointState!) ? pPeach : Colors.grey,
        submit: widget.wayPointPressed,
        title: '경로지점'
      )
    );
  }

  // 복귀 지점 추가 버튼
  Widget _rtlCommandButton() {
    return Visibility(
      visible: _isOpen,
      child: IconStringButton(
        icon: Icons.download,
        color: pPeach,
        submit: widget.rtlPressed,
        title: '복귀'
      )
    );
  }
  
  // 지도 중앙 버튼
  Widget _mapCenterButton() {
    return Visibility(
      visible: _isOpen,
      child: IconStringButton(
        icon: Icons.my_location,
        submit: widget.mapCenterPressed,
        color: pPeach,
        title: '중앙'
      )
    );
  }

  // 메뉴 버튼 구성
  Widget _toolButton() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _takeOffCommandButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _wayPointButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _rtlCommandButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _mapCenterButton(),
          
          // 메뉴 열고 닫기 버튼
          SizedBox(height: (_isOpen) ? 10 : 0),
          IconStringButton(
            icon: _isOpen ? Icons.expand_less : Icons.expand_more,
            submit: _toggleOpen,
            color: Colors.black87,
            title: _isOpen ? '닫기' : '열기',
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent
      ),
      width: 200,
      child: Padding(
        padding: const EdgeInsets.only(top: 45),
        child: _toolButton(),
      ),
    );
  }
}
