import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class VehicleInfo extends StatefulWidget {
  const VehicleInfo({
    Key? key
  }) : super(key: key);

  @override
  State<VehicleInfo> createState() => _VehicleInfoStete();
}

class _VehicleInfoStete extends State<VehicleInfo> {
  MultiVehicle manager = MultiVehicle();

  // TODO : 화면 크기에 따른 글자 크기 조정
  double getPosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if(Platform.isAndroid || Platform.isIOS) {
      if(screenSize.height * 0.15 > 95) {
        return screenSize.height * 0.15;
      } else {
        return 95;
      }
    } else {
      return screenSize.height * 0.15;
    }
  }

  EdgeInsetsGeometry getPadding(BuildContext context) {
    if(Platform.isAndroid || Platform.isIOS) {
      final screenSize = MediaQuery.of(context).size;
      return EdgeInsets.only(top: (screenSize.height * 0.05), bottom: (screenSize.height * 0.02), left: (screenSize.height * 0.06));
    } else {
      final screenSize = MediaQuery.of(context).size;
      return EdgeInsets.only(top: (screenSize.height * 0.05), bottom: (screenSize.height * 0.02), left: (screenSize.height * 0.04));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(context),
      height: getPosition(context),
      color: Colors.white,
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          Vehicle? activeVehicle = multiManager.activeVehicle();

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: StatusWidget(
                  title: "고도",
                  text: (activeVehicle != null ? activeVehicle.vehicleRelativeAltitude.toStringAsFixed(1) : '0.0'),
                  suffix: 'm'
                ),
              ),
              const VerticalDivider(thickness: 2, width: 30),
              Expanded(
                flex: 1,
                child: StatusWidget(
                  title: "방향",
                  text: (activeVehicle != null ? activeVehicle.vehicleHeading.toString() : '0'),
                  suffix: '°'
                )
              ),
              const VerticalDivider(thickness: 2, width: 30),
              Expanded(
                flex: 1,
                child: StatusWidget(
                  title: "수평 속도",
                  text: (activeVehicle != null ? activeVehicle.groundSpeed.toStringAsFixed(1) : '0.0'),
                  suffix: 'm/s'
                )
              ),
              const VerticalDivider(thickness: 2, width: 30),
              Expanded(
                flex: 1,
                child: StatusWidget(
                  title: "수직 속도",
                  text: (activeVehicle != null ? activeVehicle.climbRate.toStringAsFixed(1) : '0.0'),
                  suffix: 'm/s'
                )
              ),
              const VerticalDivider(thickness: 2, width: 30),
              Expanded(
                flex: 1,
                child: StatusWidget(
                  title: "비행모드",
                  text: (activeVehicle != null ? activeVehicle.flightMode : '-'),
                  suffix: ''
                )
              )
            ],
          );
        },
      )
    );
  }
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.suffix,
    this.subtext,
  }) : super(key: key);

  final String title;
  final String text;
  final String suffix;
  final String? subtext;

  // TODO : 화면 크기에 따른 글자 크기 조정
  double getFontSize(BuildContext context) {
    if(Platform.isAndroid || Platform.isIOS) {
      return 13;
    } else {
      final screenSize = MediaQuery.of(context).size;
      return (screenSize.height * 0.02 > 15) ? 15 : screenSize.height * 0.02;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: getFontSize(context),
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 10), // 텍스트 사이의 간격 조절을 위한 SizedBox 추가
        Text(
          '$text$suffix',
          style: TextStyle(
            fontSize: getFontSize(context),
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w300
          ),
        ),
      ],
    );
  }
}
