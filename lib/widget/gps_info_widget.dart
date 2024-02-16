import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class GpsWidget extends StatefulWidget {
  const GpsWidget({Key? key}) : super(key: key);

  @override
  State<GpsWidget> createState() => _GpsWidgetState();
}

class _GpsWidgetState extends State<GpsWidget> {
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
      width: 130,
      color: Colors.transparent,
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          Vehicle? activeVehicle = multiManager.activeVehicle();

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(
                flex: 1,
                child: Icon(
                  Icons.satellite_alt,
                  color: Colors.white,
                ),
              ),
              if(activeVehicle == null)
              const Expanded(
                flex: 2,
                child: Text(
                  'Not Connected',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w300,
                    fontSize: 12
                  ),
                ),
              ),
              if(activeVehicle != null)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activeVehicle.gpsfixTypeString,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w300,
                        fontSize: 10
                      ),
                    ),
                    Text(
                      '${activeVehicle.satVisible}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w300,
                        fontSize: 10
                      )
                    )
                  ],
                )
              ),
              if(activeVehicle != null)
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${activeVehicle.eph}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w300,
                        fontSize: 10
                      ),
                    ),
                    Text(
                      '${activeVehicle.epv}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w300,
                        fontSize: 10
                      ),
                    )
                  ],
                )
              )
            ],
          );
        },
      ),
    );
  }
}