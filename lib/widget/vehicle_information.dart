import 'package:flutter/material.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/utils/utils.dart';
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
    return Container(
      height: 80 * scaleSmallDevice(context),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black45, Colors.black26],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
      ),
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          Vehicle? activeVehicle = multiManager.activeVehicle();
          return Row(
            children: [
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Alt(Rel)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Text(
                    (activeVehicle != null ? '${activeVehicle.vehicleRelativeAltitude.toStringAsFixed(1)} m' : '0.0 m'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.only(left: 20)),
              Row(
                children: [
                  Text(
                    'GroundSpeed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Text(
                    (activeVehicle != null ? '${activeVehicle.groundSpeed.toStringAsFixed(1)} m/s' : '0.0 m/s'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.only(left: 20)),
            ],
          );
        },
      ),
    );
  }
}