import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peachgs_flutter/utils/utils.dart';

// flutter_svg 패키지를 이용해 svg 이미지를 가져온다.
class VehicleMarker extends StatelessWidget {
  final String route;
  final double radians;
  final int    vehicleId;
  final Color outlineColor; 

  const VehicleMarker({
    required this.route,
    required this.radians,
    required this.vehicleId,
    required this.outlineColor,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: radians,
              child: SvgPicture.asset(
                route,
                width: 40 * scaleSmallDevice(context),
                height: 40 * scaleSmallDevice(context),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OutlineText(
              Text(
                '기체 $vehicleId',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12 * scaleSmallDevice(context)
                ),
              ),
              strokeWidth: 1,
              strokeColor: outlineColor,
              overflow: TextOverflow.ellipsis,
            )
          )
        ],
      ),
    );
  }
}