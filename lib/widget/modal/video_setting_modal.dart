import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/model/app_setting.dart';

// 비디오 URL 설정 모달
Future<String> showVideoModal(BuildContext context) async {
  final formKey    = GlobalKey<FormState>();
  final controller = TextEditingController();

  String url = context.read<AppConfig>().url;
  controller.text = url;

  // 모달 크기 설정
  double modalHeight = (MediaQuery.of(context).size.height * 0.15 < 151) ? 152 : MediaQuery.of(context).size.height * 0.15;
  double modalWidth  = (MediaQuery.of(context).size.width  * 0.25 < 480) ? 480 : MediaQuery.of(context).size.width  * 0.25;

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 10.0),
        title: const Text(
          "비디오 설정",
          style: TextStyle(fontSize: 24.0)
        ),
        content: SizedBox(
          height: modalHeight,
          width: modalWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'URL을 입력해 주세요',
                        labelText: 'URL',
                        counterText: ''
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty) {
                          return 'URL은 비어 있을 수 없습니다';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        url = value!;
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        final formKeyState = formKey.currentState!;
                        if(formKeyState.validate()) {
                          formKeyState.save();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        "확인",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      );
    }
  ).then((_) {
    return url;
  });
}
