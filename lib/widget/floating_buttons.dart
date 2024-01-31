import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Color pBlue  = const Color(0xFF41B6E6);
Color pPeach = const Color(0xffFA828F);

class FloatingButtons extends StatefulWidget {
  const FloatingButtons({Key? key}) : super(key: key);

  @override
  State<FloatingButtons> createState() => _FloatingButtonsState();
}

class _FloatingButtonsState extends State<FloatingButtons> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.transparent,
      overlayOpacity: 0.0,
      backgroundColor: pBlue,
      activeBackgroundColor: pPeach,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.work_history, color: Colors.white),
          label: "임무 모드",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            // Do something....
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.work_history, color: Colors.white),
          label: "연결 링크 설정",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            GoRouter.of(context).push('/link');
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.work_history, color: Colors.white),
          label: "어플리케이션 설정",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            // Do something....
          }
        ),
      ],
    );
  }
}