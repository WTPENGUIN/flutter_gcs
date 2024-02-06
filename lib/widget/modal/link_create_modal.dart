import 'package:flutter/material.dart';

// 링크 생성 모달
Future<List<String>> showLinkCreateModal(BuildContext context) async {
  List<String> linkConfigure = [];
  final formKey = GlobalKey<FormState>();

  String selectedProtocol = 'UDP(S)';
  String hostName = '';
  String portNumber = '';
  
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
          "링크 설정",
          style: TextStyle(fontSize: 24.0)
        ),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          width: MediaQuery.of(context).size.width * 0.3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("프로토콜"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: InputBorder.none
                      ),
                      isExpanded: true,
                      value: selectedProtocol,
                      onChanged: (String? value) {
                        selectedProtocol = value!;
                      },
                      items: <String>['UDP(S)', 'UDP', 'TCP'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("주소"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '호스트 주소를 입력해 주세요.',
                        labelText: '호스트 주소',
                        counterText: ''
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty) {
                          return '1글자 이상 입력해 주세요.';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        hostName = value!;
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("포트 번호"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '포트 번호를 입력해 주세요.',
                        labelText: '포트번호',
                        counterText: ''
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      validator: (String? value) {
                        if(value!.isEmpty) {
                          return '1글자 이상 입력해 주세요.';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        portNumber = value!;
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
                          linkConfigure = [selectedProtocol, hostName, portNumber];
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        "저장",
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
  ).then((value) { return linkConfigure; });
}
