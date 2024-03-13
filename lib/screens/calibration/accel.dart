import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';

class CalibrationAccel extends StatefulWidget {
  const CalibrationAccel({Key? key}) : super(key: key);

  @override
  State<CalibrationAccel> createState() => _CalibrationAccelState();
}

// TODO : 실제 작동하는 캘리브레이션 기능 구현
class _CalibrationAccelState extends State<CalibrationAccel> {
  final List<String> _calImgList = [
    'accel_down.png',
    'accel_up.png',
    'accel_front.png',
    'accel_back.png',
    'accel_left.png',
    'accel_right.png'
  ];

  double _dynamicRatio() {
    if(Platform.isAndroid || Platform.isIOS) {
      return MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height);
    } else {
      return MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height * 1.3);
    }
  }

  Widget _noVehicle() {
    return const Text("기체를 먼저 연결해 주세요");
  }
  
  @override
  Widget build(BuildContext context) {
    if(MultiVehicle().activeVehicle() == null) return _noVehicle();
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                '기체를 아래 표시된 자세 중 완료되지 않은 자세대로 놓고 그대로 유지해 주십시오.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: _dynamicRatio(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  children: List.generate(6, (index) {
                    return Container(
                      color: Colors.red,
                      child: Container(
                        color: Colors.white,
                        margin: const EdgeInsets.all(3),
                        child: Image.asset('assets/image/accel_cal/${_calImgList[index]}'),
                      )
                    );
                  }),
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () { },
                    child: const Text("시작")
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () { },
                    child: const Text("중지")
                  )
                ],
              ),
            )
          ],
        ),
        AbsorbPointer(
          absorbing: MultiVehicle().activeVehicle()!.armed,
          child: Visibility(
            visible: MultiVehicle().activeVehicle()!.armed,
            child: Container(
              color: Colors.black45,
              child: const Center(
                child: Text(
                  '시동 중에는 조작할 수 없습니다.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white
                  ),
                )
              ),
            )
          ),
        )
      ],
    );
  }
}