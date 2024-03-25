import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:peachgs_flutter/widget/common_widget/outline_text.dart';

class VehicleMarker extends StatelessWidget {
  const VehicleMarker({
    Key? key,
    required this.vehicleId,
    required this.flightMode,
    required this.armed,
    required this.degree,
    this.translucent = false,
    this.outlineColor,
  }) : super(key: key);
  
  final int     vehicleId;    // 기체 번호
  final String  flightMode;   // 비행 모드
  final bool    armed;        // 시동 여부
  final double  degree;       // 기체 Yaw 각도
  final bool    translucent;  // 반투명 여부
  final Color?  outlineColor; // 글씨 강조 색깔

  double _degreesToRadians(double degrees) {
    const double pi = 3.1415926535897932;

    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: _degreesToRadians(degree),
              child: SvgPicture.asset(
                'assets/image/VehicleIcon.svg',
                width: 40,
                height: 40,
                colorFilter: ColorFilter.mode(translucent ? const Color.fromRGBO(255, 255, 255, 0.5) : const Color.fromRGBO(255, 255, 255, 1.0), BlendMode.modulate)
              )
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OutlineText(
              strokeWidth: 1,
              strokeColor: outlineColor,
              overflow: TextOverflow.ellipsis,
              child: Text(
                '기체 $vehicleId(${armed ? '시동' : '꺼짐'})',
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 10,
                  color: Colors.white
                )
              )
            )
          ),
          Align(
            alignment: Alignment.topCenter,
            child: OutlineText(
              strokeWidth: 1,
              strokeColor: outlineColor,
              overflow: TextOverflow.ellipsis,
              child: Text(
                flightMode,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.white
                )
              )
            )
          )
        ]
      )
    );
  }
}