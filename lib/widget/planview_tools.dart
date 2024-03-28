import 'package:flutter/material.dart';

import 'package:peachgs_flutter/colors.dart';
import 'package:peachgs_flutter/widget/common_widget/icon_string_button.dart';

class PlanViewTools extends StatefulWidget {
  const PlanViewTools({
    required this.setFly,
    required this.mapCenter,
    Key? key,
  }) : super(key: key);

  final Function() setFly;
  final Function() mapCenter;

  @override
  State<PlanViewTools> createState() => _PlanViewToolsState();
}

class _PlanViewToolsState extends State<PlanViewTools> {
  bool _isMenuOpen = true; // 도구 모음 열림 상태

  void _toggleOpen() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  // 비행 모드 전환 버튼
  Widget _setFlyButton() {
    return IconStringButton(
      icon: Icons.flight,
      color: Colors.black,
      submit: widget.setFly,
      title: '비행'
    );
  }

  // 이륙 명령어 추가 버튼
  Widget _takeOffCommandButton() {
    return IconStringButton(
      icon: Icons.file_upload,
      color: pPeach,
      submit: null, // TODO : 비행 계획에 이륙 명령어 추가
      title: '이륙'
    );
  }

  // 경로 지점 추가 버튼
  Widget _wayPointButton() {
    return IconStringButton(
      icon: Icons.control_point,
      color: pPeach,
      submit: null, // TODO : 비행 계획에 경로 지점 추가
      title: '경로 지점'
    );
  }

  // 복귀 명령어 추가 버튼
  Widget _rtlCommandButton() {
    return IconStringButton(
      icon: Icons.download,
      color: pPeach,
      submit: null, // TODO : 비행 계획에 복귀 명령어 추가
      title: '복귀'
    );
  }
  
  // 기체 위치로 지도 이동 버튼
  Widget _mapCenterButton() {
    return IconStringButton(
      icon: Icons.my_location,
      submit: widget.mapCenter,
      color: pPeach,
      title: '중앙'
    );
  }

  // 메뉴 버튼 구성
  Widget _toolButton() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(visible: _isMenuOpen, child: _setFlyButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _takeOffCommandButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _wayPointButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _rtlCommandButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _mapCenterButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),
          
          // 메뉴 열고 닫기 버튼
          IconStringButton(
            icon: _isMenuOpen ? Icons.expand_less : Icons.expand_more,
            submit: _toggleOpen,
            color: Colors.black87,
            title: _isMenuOpen ? '닫기' : '열기',
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
        padding: const EdgeInsets.all(10),
        child: _toolButton(),
      ),
    );
  }
}
