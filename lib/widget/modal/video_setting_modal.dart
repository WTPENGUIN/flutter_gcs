import 'package:flutter/material.dart';

// 링크 생성 모달
Future<String> showVideoModal(BuildContext context) async {
  final formKey = GlobalKey<FormState>();

  String url = '';
  
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
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.2,
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
  ).then((value) { return url; });
}
