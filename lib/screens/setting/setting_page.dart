import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:peachgs_flutter/model/app_setting.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _mavlinkId = TextEditingController();
  final TextEditingController _rtspUrl = TextEditingController();

  void _showErrorMessage(String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
      ),
      snackBarPosition: SnackBarPosition.top
    );
  }

  void _showSuccessMessage(String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
      ),
      snackBarPosition: SnackBarPosition.top
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _mavlinkId.text = AppSetting().id.toString();
    _rtspUrl.text = AppSetting().url;

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
        platform: DevicePlatform.iOS,
        applicationType: ApplicationType.both,
        sections: [
          SettingsSection(
            title: const Text(
              'Mavlink',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.settings_input_antenna),
                title: Row(
                  children: [
                    const Text('Mavlink System ID'),
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
                          int? val = int.tryParse(value);
                          if(val == null) {
                            _showErrorMessage('올바른 숫자를 입력해 주세요.');
                            return;
                          } else {
                            if(val <= 0 || val > 255 ) {
                              _showErrorMessage('Mavlink ID 범위를 확인해 주세요.');
                              return;
                            }
                            AppSetting().updateMavId(val);
                            _showSuccessMessage('설정이 완료 되었습니다.');
                          }
                        },
                      ),
                    )
                  ],
                ),
                description: const Text('지상 제어 어플리케이션의 Mavlink System ID를 지정합니다(1~255).'),
              ),
            ],
          ),
          // TODO : 비디오 스트리밍 URL 설정
          SettingsSection(
            title: const Text(
              'Video',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.movie),
                title: Row(
                  children: [
                    const Text('URL'),
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
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
                        maxLines: 1,
                        onSubmitted: (value) {
                          // Do something...
                        },
                      ),
                    )
                  ],
                ),
                description: const Text('Video Streaming 주소를 설정합니다(rtsp 혹은 http 주소만 허용됩니다).'),
              ),
            ],
          ),
        ],
      )
    );
  }
}