import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/colors.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/common_widget/icon_string_button.dart';
import 'package:peachgs_flutter/widget/altitudeslider.dart';

class FlyViewTools extends StatefulWidget {
  const FlyViewTools({
    required this.setPlan,
    Key? key,
  }) : super(key: key);

  final void Function() setPlan;

  @override
  State<FlyViewTools> createState() => _FlyViewToolsState();
}

class _FlyViewToolsState extends State<FlyViewTools> {
  bool _isMenuOpen   = true;  // 메뉴 열림 변수
  bool _isShowSlider = false; // 슬라이더 표출 변수
  bool _isTakeOff    = false; // 이륙 여부 변수

  void _toggleOpen() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    // 슬라이더가 표시되어 있으면, 슬라이더도 닫아 줌.
    if(_isShowSlider) {
      setState(() {
        _isShowSlider = !_isShowSlider;
      });
    }
  }

  void _toggleSlider() {
    setState(() {
      _isShowSlider = !_isShowSlider;
    });
  }

  // 계획 모드 전환 버튼
  Widget _setPlanButton() {
    return IconStringButton(
      icon: Icons.edit_road,
      color: Colors.black,
      submit: widget.setPlan,
      title: '임무',
    );
  }

  // 이륙 버튼
  Widget _takeOffButton() {
    return Selector<MultiVehicle, bool?>(
      selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
      builder: (context, isFlying, _) {
        bool flying = (isFlying != null) && !isFlying;
        return IconStringButton(
          icon: Icons.file_upload,
          color: (flying) ? pBlue : Colors.grey,
          submit: (flying) ? () {
            _isTakeOff = true;
            _toggleSlider();
          } : null,
          title: '이륙',
        );
      }
    );
  }

  // 고도 변경 버튼
  Widget _changeAltButton() {
    return Selector<MultiVehicle, bool?>(
      selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
      builder: (context, isFlying, _) {
        bool flying = (isFlying != null) && isFlying;
        return IconStringButton(
          icon: Icons.published_with_changes,
          color: (flying) ? pBlue : Colors.grey,
          submit: flying ? () {
            _isTakeOff = false;
            _toggleSlider();
          } : null,
          title: '변경',
        );
      }
    );
  }

  // 착륙 버튼
  Widget _landButton() {
    return Selector<MultiVehicle, bool?>(
      selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
      builder: (context, isFlying, _) {
        bool flying = (isFlying != null) && isFlying;
        return IconStringButton(
          icon: Icons.download,
          color: (flying) ? pBlue : Colors.grey,
          submit: flying ? () {
            var vehicle = MultiVehicle().activeVehicle();
            if(vehicle == null) return;
            
            vehicle.land();
          } : null,
          title: '착륙',
        );
      }
    );
  }

  // RTL 버튼
  Widget _rtlButton() {
    return Selector<MultiVehicle, bool?>(
      selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
      builder: (context, isFlying, _) {
        bool flying = (isFlying != null) && isFlying;
        return IconStringButton(
          icon: Icons.keyboard_return,
          color: (flying) ? pBlue : Colors.grey,
          submit: flying ? () {
            var vehicle = MultiVehicle().activeVehicle();
            if(vehicle == null) return;
              
            vehicle.rtl();
          } : null,
          title: '복귀',
        );
      }
    );
  }

  // 메뉴 버튼 구성
  Widget _toolButton() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(visible: _isMenuOpen, child: _setPlanButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _takeOffButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),

          Visibility(visible: _isMenuOpen, child: _changeAltButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),
          
          Visibility(visible: _isMenuOpen, child: _landButton()),
          SizedBox(height: (_isMenuOpen) ? 10 : 0),
          
          Visibility(visible: _isMenuOpen, child: _rtlButton()),
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
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent
            ),
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _toolButton(),
            ),
          ),
        ),
        Visibility(
          visible: _isShowSlider,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AltitudeSlider(
                takeOff: _isTakeOff,
                submit: _toggleSlider,
                height: MediaQuery.of(context).size.height
              )
            )
          )
        )
      ],
    );
  }
}
