import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class VehicleInfo extends StatelessWidget {
  const VehicleInfo({Key? key}) : super(key: key);

  // 화면 크기에 따른 패딩 크기
  EdgeInsetsGeometry getPadding(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if(Platform.isAndroid || Platform.isIOS) {
      return EdgeInsets.only(top: (screenSize.height * 0.05), bottom: (screenSize.height * 0.02), left: (screenSize.height * 0.04));
    } else {
      return EdgeInsets.only(top: (screenSize.height * 0.05), bottom: (screenSize.height * 0.02), left: (screenSize.height * 0.06));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(context),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Selector<MultiVehicle, double?>(
              selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.vehicleRelativeAltitude,
              builder: (context, altitude, _) {
                return StatusWidget(
                  title: "고도",
                  text: (altitude != null) ? altitude.toStringAsFixed(1) : '0.0',
                  suffix: 'm'
                );
              },
            )
          ),
          const VerticalDivider(thickness: 2, width: 30),
          Expanded(
            flex: 1,
            child: Selector<MultiVehicle, int?>(
              selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.vehicleHeading,
              builder: (context, heading, _) {
                return StatusWidget(
                  title: '방향',
                  text: (heading != null) ? heading.toString() : '0',
                  suffix: '°'
                );
              },
            )
          ),
          const VerticalDivider(thickness: 2, width: 30),
          Expanded(
            flex: 1,
            child: Selector<MultiVehicle, double?>(
              selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.groundSpeed,
              builder: (context, verticalSpeed, _) {
                return StatusWidget(
                  title: '수평 속도',
                  text: (verticalSpeed != null) ? verticalSpeed.toStringAsFixed(1) : '0.0',
                  suffix: 'm/s'
                );
              },
            )
          ),
          const VerticalDivider(thickness: 2, width: 30),
          Expanded(
            flex: 1,
            child: Selector<MultiVehicle, double?>(
              selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.climbRate,
              builder: (context, horizentalSpeed, _) {
                return StatusWidget(
                  title: '수직 속도',
                  text: (horizentalSpeed != null) ? horizentalSpeed.toStringAsFixed(1) : '0.0',
                  suffix: 'm/s'
                );
              },
            )
          ),
          const VerticalDivider(thickness: 2, width: 30),
          Expanded(
            flex: 1,
            child: Selector<MultiVehicle, String?>(
              selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.flightMode,
              builder: (context, mode, _) {
                return StatusWidget(
                  title: '비행 모드',
                  text: (mode != null) ? mode : '-',
                );
              },
            )
          ),
        ],
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({
    Key? key,
    required this.title,
    required this.text,
    this.suffix = '',
    this.subtext,
  }) : super(key: key);

  final String title;
  final String text;
  final String? suffix;
  final String? subtext;

  // TODO : 화면 크기에 따른 글자 크기 조정
  double getFontSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if(Platform.isAndroid || Platform.isIOS) {
      return (screenSize.height * 0.02 > 15) ? 15 : screenSize.height * 0.02;
    } else {
      return 15;
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
