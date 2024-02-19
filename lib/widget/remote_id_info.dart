import 'package:flutter/material.dart';

class RemoteIdInfo extends StatelessWidget {
  const RemoteIdInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      color: Colors.transparent,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          )
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),
                child: SizedBox(
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FlutterLogo(size: 150),
                      const Text(
                        "조종자 위치 : 34.610958, 127.205672",
                        style:TextStyle(fontSize: 12)
                      ),
                      const Text(
                        "드론 위치 : 34.610958, 127.205672",
                        style:TextStyle(fontSize: 12)
                      ),
                      const Text(
                        "기체 종류 : 쿼드콥터",
                        style:TextStyle(fontSize: 12)
                      ),
                      const Text(
                        "제조사 : The Peach.inc",
                        style:TextStyle(fontSize: 12)
                      ),
                      const Text(
                        "Remote ID : 2384902374",
                        style:TextStyle(fontSize: 12)
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.black
                          ),
                        )
                      )
                    ],
                  ),
                )
              );
            }
          );
        },
        icon: const Icon(
          Icons.info,
          color: Colors.white,
        ),
        label: const Text(
          "정보",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11
          ),
        ),
      ),
    );
  }
}