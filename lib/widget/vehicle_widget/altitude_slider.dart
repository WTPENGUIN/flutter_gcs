import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class AltitudeSlider extends StatefulWidget {
  const AltitudeSlider({
    Key? key,
    required this.takeOff,
    required this.submit
  }) : super(key: key);

  final bool        takeOff;
  final Function()? submit;

  @override
  State<AltitudeSlider> createState() => _AltitudeSliderState();
}

class _AltitudeSliderState extends State<AltitudeSlider> {
  int _sliderValue = (MultiVehicle().activeVehicle() == null) ? 0 : MultiVehicle().activeVehicle()!.alt.toInt();

  // TODO : 반응형 높이
  double _dynamicHeight() {
    double calHeight = MediaQuery.of(context).size.height * 0.45;

    if(calHeight > 320) {
      return 320.0;
    } else {
      return calHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: _dynamicHeight(),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FlutterSlider(
              axis: Axis.vertical,
              trackBar: FlutterSliderTrackBar(
                activeTrackBarHeight: 7,
                inactiveTrackBarHeight: 10,
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white38,
                ),
                activeTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue
                )
              ),
              tooltip: FlutterSliderTooltip(
                direction: FlutterSliderTooltipDirection.right,
                positionOffset: FlutterSliderTooltipPositionOffset(
                  right: -10
                ),
                format:(String value) {
                  return '${value}m';
                },
                textStyle: const TextStyle(fontWeight: FontWeight.w100, fontFamily: 'Orbitron'),
                boxStyle: FlutterSliderTooltipBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              ),
              selectByTap: false,
              rtl: true,
              values: [_sliderValue.toDouble()],
              min: 0,
              max: 100 + (_sliderValue * 1.5),
              onDragging: (_, lowerValue, __) {
                _sliderValue = lowerValue.toInt();
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white
              ),
              onPressed: () {
                // 상위 위젯에서 전달받은 함수 실행
                widget.submit!();
                
                if(MultiVehicle().activeVehicle() == null) return;
                if(widget.takeOff) {
                  MultiVehicle().activeVehicle()!.takeOff(_sliderValue.toDouble());
                } else {
                  var newAlt = _sliderValue.toDouble() - MultiVehicle().activeVehicle()!.alt;
                  MultiVehicle().activeVehicle()!.changeAltitude(newAlt);
                }
              },
              icon: const Icon(Icons.check, color: Colors.black),
            )
          )
        ]
      )
    );
  }
}