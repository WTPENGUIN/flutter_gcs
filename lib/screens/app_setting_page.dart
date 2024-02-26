import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import 'package:peachgs_flutter/utils/mavlink_protocol.dart';

class AppSettingPage extends StatefulWidget {
  const AppSettingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AppSettingPage> createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  final TextEditingController _mavlinkId = TextEditingController();
  final TextEditingController _rtspUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mavlinkId.text = MavlinkProtocol.getSystemId().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('어플리케이션 설정'),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text(
              'Mavlink',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.settings_input_antenna),
                title: Row(
                  children: [
                    const Text('Mavlink ID'),
                    const Spacer(),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _mavlinkId,
                        decoration: const InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 0.5)
                          ),
                          contentPadding: EdgeInsets.all(5),
                          counterText: ''
                        ),
                        cursorColor: Colors.black54,
                        cursorHeight: 20,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        onSubmitted: (value) {
                          // Do something...
                        },
                      ),
                    )
                  ],
                ),
                description: const Text('GCS의 Mavlink ID를 설정합니다.(숫자 3자리)'),
              ),
            ],
          ),
          // TODO : 비디오 스트리밍 URL 설정
          SettingsSection(
            title: const Text('Video'),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.movie),
                title: Row(
                  children: [
                    const Text('URL'),
                    const Spacer(),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _rtspUrl,
                        decoration: const InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 0.5)
                          ),
                          contentPadding: EdgeInsets.all(5),
                          counterText: ''
                        ),
                        cursorColor: Colors.black54,
                        cursorHeight: 20,
                        textAlign: TextAlign.right,
                        maxLength: 30,
                        onSubmitted: (value) {
                          // Do something...
                        },
                      ),
                    )
                  ],
                ),
                description: const Text('Video Streaming 주소를 설정합니다.(rtsp 혹은 http 주소만 허용됩니다.)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}