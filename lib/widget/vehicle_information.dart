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
      height: 100 * scaleSmallDevice(context),
      width: 300 * scaleSmallDevice(context),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: const Color(0x99808080)
      ),
      child: Selector<MultiVehicle, int>(
        selector: (_, active) => active.getActiveId,
        builder: (_, activeID, __) {
          Vehicle? activeVehicle = manager.activeVehicle();
          return Row(
            children: [
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
                    (activeVehicle != null ? '${activeVehicle.relativeAltitude.toStringAsFixed(1)} m' : '0.0 m'),
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
                    'HDOP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Text(
                    (activeVehicle != null ? activeVehicle.eph.toStringAsFixed(1) : '100.0'),
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
                    'VDOP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Text(
                    (activeVehicle != null ? activeVehicle.epv.toStringAsFixed(1) : '100.0'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12 * scaleSmallDevice(context)
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}