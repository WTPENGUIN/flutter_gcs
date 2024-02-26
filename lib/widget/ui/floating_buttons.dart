import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/utils/connection_manager.dart';
import 'package:peachgs_flutter/widget/modal/link_create_modal.dart';

Color pBlue  = const Color(0xFF41B6E6);
Color pPeach = const Color(0xffFA828F);

class FloatingButtons extends StatefulWidget {
  const FloatingButtons({Key? key}) : super(key: key);

  @override
  State<FloatingButtons> createState() => _FloatingButtonsState();
}

// TODO : 화면 크기에 따른 하위 버튼 크기 조절
class _FloatingButtonsState extends State<FloatingButtons> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.transparent,
      overlayOpacity: 0.0,
      backgroundColor: pPeach,
      activeBackgroundColor: pBlue,
      direction: SpeedDialDirection.down,
      buttonSize: const Size(40,40),
      childrenButtonSize: const Size(40, 40),
      spacing: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.tune, color: Colors.white),
          label: "기체 설정",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 12.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            context.push('/cal');
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.link, color: Colors.white),
          label: "링크 연결",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 12.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () async {
            var link = await showLinkCreateModal(context);
            if(link.isEmpty) return;

            String protocol = link[0];
            String host = link[1];
            int port = int.parse(link[2]);

            switch (protocol) {
              case 'TCP':
                if (context.mounted) Provider.of<ConnectionManager>(context, listen: false).startTCPTask(host, port);
                break;
              case 'UDP(S)':
                if (context.mounted) Provider.of<ConnectionManager>(context, listen: false).startUDPServerTask(port);
                break;
              case 'UDP':
                if (context.mounted) Provider.of<ConnectionManager>(context, listen: false).startUDPClientTask(host, port);
                break;                
              default:
                return;
            }
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.link_off, color: Colors.white),
          label: "링크 해제",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 12.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            Provider.of<ConnectionManager>(context, listen: false).stopAllTask();
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.settings, color: Colors.white),
          label: "App 설정",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 12.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            context.push('/setting');
          }
        ),
      ],
    );
  }
}