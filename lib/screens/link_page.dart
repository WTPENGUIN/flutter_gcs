import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/utils/link_manage.dart';

class LinkSettingWindow extends StatefulWidget {
  const LinkSettingWindow({Key? key}) : super(key: key);

  @override
  State<LinkSettingWindow> createState() => _LinkSettingWindowState();
}

class _LinkSettingWindowState extends State<LinkSettingWindow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await Provider.of<LinkTaskManager>(context, listen: false).startUDPTask('0.0.0.0', 15000);
            },
            child: const Text('링크 테스트 시작')
          ),
          const Padding(padding: EdgeInsets.only(bottom: 20)),
          ElevatedButton(
            onPressed: () {
              Provider.of<LinkTaskManager>(context, listen: false).stopUDPTask('0.0.0.0', 15000);
            },
            child: const Text('링크 테스트 종료')
          ),
          const Padding(padding: EdgeInsets.only(bottom: 20)),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            child: const Text('뒤로 가기')
          ),
        ],
      ),
      )
    );
  }
}