import 'package:flutter/material.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:provider/provider.dart';

class VehicleInfo extends StatefulWidget {
  const VehicleInfo({Key? key}) : super(key: key);

  @override
  State<VehicleInfo> createState() => _VehicleInfoStete();
}

class _VehicleInfoStete extends State<VehicleInfo> {
  MultiVehicle manager = MultiVehicle();

  @override
  Widget build(BuildContext context) {
    const double widgetWidth  = 300;
    const double widgetHeight = 80;

    return Container(
      width: widgetWidth,
      height: widgetHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black38,
      ),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          height: 55,
          child: Consumer<MultiVehicle>(
            builder: (_, multiManager, __) {
              Vehicle? activeVehicle = multiManager.activeVehicle();
              
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 5.0,
                children: [
                  InfoTile(value: (activeVehicle != null ? activeVehicle.distanceToHome.toStringAsFixed(0)          : '0'  ), prefix: 'D', suffix: 'm',   screenWidth: widgetWidth),
                  InfoTile(value: (activeVehicle != null ? activeVehicle.vehicleRelativeAltitude.toStringAsFixed(1) : '0.0'), prefix: 'A', suffix: 'm',   screenWidth: widgetWidth),
                  InfoTile(value: (activeVehicle != null ? activeVehicle.groundSpeed.toStringAsFixed(1)             : '0.0'), prefix: 'H', suffix: 'm/s', screenWidth: widgetWidth),
                  InfoTile(value: (activeVehicle != null ? activeVehicle.climbRate.toStringAsFixed(1)               : '0.0'), prefix: 'V', suffix: 'm/s', screenWidth: widgetWidth),
                ],
              );
            },
          ),
        )
      )
    );
  }
}

class InfoTile extends StatelessWidget {
  final String value;
  final String prefix;
  final String suffix;
  final double screenWidth;

  const InfoTile({
    required this.value,
    required this.prefix,
    required this.suffix,
    required this.screenWidth,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontSize: 10.0 * (screenWidth / 200.0),
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Center(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: 13.0 * (screenWidth / 200.0),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 5)),
        Expanded(
          child: Text(
            suffix,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontSize: 10.0 * (screenWidth / 200.0),
            ),
          ),
        ),
      ],
    );
  }
}