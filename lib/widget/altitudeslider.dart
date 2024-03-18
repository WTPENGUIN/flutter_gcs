import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import 'package:peachgs_flutter/provider/multivehicle.dart';

class AltitudeSlider extends StatefulWidget {
  const AltitudeSlider({
    Key? key,
    required this.takeOff,
    required this.submit,
    required this.height
  }) : super(key: key);

  final bool        takeOff;
  final Function()? submit;
  final double      height;

  @override
  State<AltitudeSlider> createState() => _AltitudeSliderState();
}

class _AltitudeSliderState extends State<AltitudeSlider> {
  int _initValue = 0;
  int _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    _initValue = (MultiVehicle().activeVehicle() == null) ? 0 : MultiVehicle().activeVehicle()!.alt.toInt();
    _sliderValue = _initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      constraints: BoxConstraints( 
        maxHeight: MediaQuery.of(context).size.height * 0.5
      ),
      height: (widget.height <= 0.0) ? MediaQuery.of(context).size.height * 0.5 : widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${_sliderValue}m',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                fontFamily: 'Orbitron',
                color: Colors.white
              ),
            ),
          ),
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
              max: 100 + (_initValue * 1.5),
              onDragging: (_, lowerValue, __) {
                setState(() {
                  _sliderValue = lowerValue.toInt();
                });
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
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