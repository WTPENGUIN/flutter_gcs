import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:peachgs_flutter/widget/component_widget/outline_text.dart';

class VehicleMarker extends StatelessWidget {
  const VehicleMarker({
    Key? key,
    required this.route,
    required this.degree,
    required this.vehicleId,
    required this.outlineColor,
    required this.flightMode,
    required this.armed
  }) : super(key: key);

  final String route;
  final double degree;
  final int    vehicleId;
  final Color  outlineColor;
  final String flightMode;
  final bool   armed;

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
                route,
                width: 40,
                height: 40,
              ),
            ),
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
                ),
              ),
            ),
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
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}