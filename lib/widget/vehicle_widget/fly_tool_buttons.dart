import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/component_widget/tool_button.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/altitude_slider.dart';

Color pBlue = const Color(0xFF41B6E6);

class FlyButtons extends StatefulWidget {
  const FlyButtons({
    Key? key,
    this.buttonState,
    this.mapSubmit
  }) : super(key: key);

  final bool?       buttonState;
  final Function()? mapSubmit;

  @override
  State<FlyButtons> createState() => _ToolButtonsState();
}

class _ToolButtonsState extends State<FlyButtons> {
  bool _isOpen     = true;
  bool _showSlider = false;
  bool _isTakeOff  = false;

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
    });

    // 슬라이더 표출 시, 슬라이더도 닫아 줌.
    if(_showSlider) {
      setState(() {
        _showSlider = !_showSlider;
      });
    }
  }

  void _toggleSlider() {
    setState(() {
      _showSlider = !_showSlider;
    });
  }

  // 시동 버튼
  Widget _armButton() {
    return Visibility(
      visible: _isOpen,
      child: Selector<MultiVehicle, bool?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.armed,
        builder: (context, isArmed, _) {
          bool armAble = (isArmed != null) && !isArmed;
          return ToolButton(
            icon: armAble ? Icons.power_settings_new : Icons.highlight_off,
            color: armAble ? pBlue : Colors.grey,
            submit: armAble ? () {
              Vehicle? vehicle = MultiVehicle().activeVehicle();
              if(vehicle == null) return;

              if(armAble) {
                vehicle.arm(true);
              } else {
                vehicle.arm(false);
              }
            } : null,
            title: armAble ? '시동' : '꺼짐',
          );
        }
      )
    );
  }

  // 이륙 버튼
  Widget _takeOffButton() {
    return Visibility(
      visible: _isOpen,
      child: Selector<MultiVehicle, bool?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
        builder: (context, isFlying, _) {
          bool flying = (isFlying != null) && !isFlying;
          return ToolButton(
            icon: Icons.file_upload,
            color: (flying) ? pBlue : Colors.grey,
            submit: (flying) ? () {
              _isTakeOff = true;
              _toggleSlider();
            } : null,
            title: '이륙',
          );
        }
      )
    );
  }

  // 고도 변경 버튼
  Widget _changeAltButton() {
    return Visibility(
      visible: _isOpen,
      child: Selector<MultiVehicle, bool?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
        builder: (context, isFlying, _) {
          bool flying = (isFlying != null) && isFlying;
          return ToolButton(
            icon: Icons.published_with_changes,
            color: (flying) ? pBlue : Colors.grey,
            submit: flying ? () {
              _isTakeOff = false;
              _toggleSlider();
            } : null,
            title: '변경',
          );
        }
      )
    );
  }

  // 착륙 버튼
  Widget _landButton() {
    return Visibility(
      visible: _isOpen,
      child: Selector<MultiVehicle, bool?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
        builder: (context, isFlying, _) {
          bool flying = (isFlying != null) && isFlying;
          return ToolButton(
            icon: Icons.download,
            color: (flying) ? pBlue : Colors.grey,
            submit: flying ? () {
              Vehicle? vehicle = MultiVehicle().activeVehicle();
              if(vehicle == null) return;
              
              vehicle.land();
            } : null,
            title: '착륙',
          );
        }
      )
    );
  }

  // RTL 버튼
  Widget _rtlButton() {
    return Visibility(
      visible: _isOpen,
      child: Selector<MultiVehicle, bool?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFly,
        builder: (context, isFlying, _) {
          bool flying = (isFlying != null) && isFlying;
          return ToolButton(
            icon: Icons.keyboard_return,
            color: (flying) ? pBlue : Colors.grey,
            submit: flying ? () {
              Vehicle? vehicle = MultiVehicle().activeVehicle();
              if(vehicle == null) return;
              
              vehicle.rtl();
            } : null,
            title: '귀환',
          );
        }
      )
    );
  }
  
  // 이동 명령 버튼
  Widget _gotoButton() {
    return Visibility(
      visible: _isOpen && (widget.buttonState != null),
      child: ToolButton(
        icon: Icons.flag,
        submit: widget.mapSubmit,
        color: (widget.buttonState != null && widget.buttonState!) ? pBlue : Colors.grey,
        title: '이동',
      )
    );
  }

  // 메뉴 버튼 구성
  Widget _toolButton() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _armButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _takeOffButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _changeAltButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _landButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _rtlButton(),
          SizedBox(height: (_isOpen) ? 10 : 0),
          _gotoButton(),
          
          // 메뉴 열고 닫기 버튼
          SizedBox(height: (_isOpen && (widget.buttonState != null)) ? 10 : 0),
          ToolButton(
            icon: _isOpen ? Icons.expand_less : Icons.expand_more,
            submit: _toggleOpen,
            color: Colors.black87,
            title: _isOpen ? '닫기' : '열기',
          )
        ],
      ),
    );
  }

  // 고도 슬라이더
  Widget _altitudeSlide() {
    return Align(
      alignment: Alignment.topCenter,
      child: Visibility(
        visible: _showSlider,
        child: AltitudeSlider(
          takeOff: _isTakeOff,
          submit: _toggleSlider
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _toolButton(),
            SizedBox(width: (_isOpen) ? 10 : 0),
            _altitudeSlide()
          ],
        )
      )
    );
  }
}
