import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/component_widget/tool_button.dart';

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
  bool isOpen = true;

  void _toggleOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 시동 버튼
            Visibility(
              visible: isOpen,
              child: Selector<MultiVehicle, bool?>(
                selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.armed,
                builder: (context, isArmed, _) {
                  bool armAble = (isArmed != null) && !isArmed;

                  return ToolButton(
                    icon: armAble ? Icons.power_settings_new : Icons.highlight_off,
                    color: armAble ? Colors.blue : Colors.grey,
                    submit: armAble ? () {
                      Vehicle? vehicle = MultiVehicle().activeVehicle();
                      if(vehicle == null) return;

                      if(armAble) {
                        vehicle.vehicleArm(true);
                      } else {
                        vehicle.vehicleArm(false);
                      }
                    } : null,
                    title: armAble ? '시동' : '꺼짐',
                  );
                }
              )
            ),
            SizedBox(height: (isOpen) ? 10 : 0),
            // 이륙 버튼
            // TODO : 고도 설정하여 이륙
            Visibility(
              visible: isOpen,
              child: Selector<MultiVehicle, bool?>(
                selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFlying,
                builder: (context, isFlying, _) {
                  bool flying = (isFlying != null) && isFlying;

                  return ToolButton(
                    icon: Icons.file_upload,
                    color: (!flying) ? Colors.blue : Colors.grey,
                    submit: (!flying) ? () {
                      Vehicle? vehicle = MultiVehicle().activeVehicle();
                      if(vehicle == null) return;

                      vehicle.vehicleTakeOff(10.0);
                    } : null,
                    title: '이륙',
                  );
                }
              )
            ),
            SizedBox(height: (isOpen) ? 10 : 0),
            // 착륙 버튼
            Visibility(
              visible: isOpen,
              child: Selector<MultiVehicle, bool?>(
                selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFlying,
                builder: (context, isFlying, _) {
                  bool flying = (isFlying != null) && isFlying;

                  return ToolButton(
                    icon: Icons.download,
                    color: (flying) ? Colors.blue : Colors.grey,
                    submit: flying ? () {
                      Vehicle? vehicle = MultiVehicle().activeVehicle();
                      if(vehicle == null) return;

                      vehicle.vehicleLand();
                    } : null,
                    title: '착륙',
                  );
                }
              )
            ),
            SizedBox(height: (isOpen) ? 10 : 0),
            // RTL 버튼
            Visibility(
              visible: isOpen,
              child: Selector<MultiVehicle, bool?>(
                selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.isFlying,
                builder: (context, isFlying, _) {
                  bool flying = (isFlying != null) && isFlying;

                  return ToolButton(
                    icon: Icons.keyboard_return,
                    color: (flying) ? Colors.blue : Colors.grey,
                    submit: flying ? () {
                      Vehicle? vehicle = MultiVehicle().activeVehicle();
                      if(vehicle == null) return;

                      vehicle.vehicleRTL();
                    } : null,
                    title: '귀환',
                  );
                }
              )
            ),
            SizedBox(height: (isOpen) ? 10 : 0),
            // 이동 명령 버튼
            Visibility(
              visible: isOpen && (widget.buttonState != null),
              child: ToolButton(
                icon: Icons.flag,
                submit: widget.mapSubmit,
                color:  (widget.buttonState != null && widget.buttonState!) ? Colors.blue : Colors.grey,
              )
            ),
            SizedBox(height: (isOpen && (widget.buttonState != null)) ? 10 : 0),
            // 메뉴 열고 닫기 버튼
            ToolButton(
              icon: isOpen ? Icons.expand_less : Icons.expand_more,
              submit: _toggleOpen,
              color: Colors.black38,
              title: isOpen ? '닫기' : '열기',
            )
          ],
        )
      )
    );
  }
}
