import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/model/app_setting.dart';

// 비디오 URL 설정 모달
Future<String> showVideoModal(BuildContext context) async {
  final formKey    = GlobalKey<FormState>();
  final controller = TextEditingController();

  String url = context.read<AppConfig>().url;
  controller.text = url;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "비디오 설정",
              style: TextStyle(fontSize: 24.0)
            ),
            const Spacer(),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black
              ),
              onPressed: () { Navigator.of(context).pop(); },
              icon: const Icon(Icons.close, color: Colors.white)
            )
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(
            minHeight: 150,
            minWidth: 480
          ),
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width  * 0.25,
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
                      // 클릭하였을 때, 모든 텍스트 선택
                      onTap: () {
                        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);
                      },
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
