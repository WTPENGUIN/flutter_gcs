import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
          child: const Icon(Icons.link, color: Colors.white),
          label: "링크 연결",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () async {
            var link = await showLinkCreateModal(context);
            if(link.isEmpty || !mounted) return;

            String protocol = link[0];
            String host = link[1];
            int port = int.parse(link[2]);

            switch (protocol) {
              case 'TCP':
                Provider.of<ConnectionManager>(context, listen: false).startTCPTask(host, port);
                break;
              case 'UDP(S)':
                Provider.of<ConnectionManager>(context, listen: false).startUDPServerTask(port);
                break;
              case 'UDP':
                Provider.of<ConnectionManager>(context, listen: false).startUDPClientTask(host, port);
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
            fontSize: 13.0
          ),
          backgroundColor: pBlue,
          labelBackgroundColor: pBlue,
          onTap: () {
            Provider.of<ConnectionManager>(context, listen: false).stopAllTask();
          }
        ),
        SpeedDialChild(
          child: const Icon(Icons.settings, color: Colors.white),
          label: "설정",
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