import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/utils/link_manage.dart';

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
          label: "테스트 링크 연결",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () async {
            if(!mounted) return;
            await Provider.of<LinkTaskManager>(context, listen: false).startUDPTask('0.0.0.0', 15000);

            if(!mounted) return;
            await Provider.of<LinkTaskManager>(context, listen: false).startTCPTask('192.168.0.35', 8888);
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.work_history, color: Colors.white),
          label: "테스트 링크 해제",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            Provider.of<LinkTaskManager>(context, listen: false).stopUDPTask('0.0.0.0', 15000);
            Provider.of<LinkTaskManager>(context, listen: false).stopTCPTask('192.168.0.35', 8888);
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