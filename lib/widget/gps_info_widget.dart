import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class GPSWidget extends StatelessWidget {
  const GPSWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      color: Colors.transparent,
      child: Selector<MultiVehicle, Vehicle?>(
        selector: (context, multiVehicle) => multiVehicle.activeVehicle(),
        builder: (context, activeVehicle, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(
                flex: 1,
                child: Icon(
                  Icons.satellite_alt,
                  color: Colors.white,
                )
              ),
              if(activeVehicle == null)
              const Expanded(
                flex: 2,
                child: Text(
                  "Not Connected",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    ),
                    Text(
                      '${activeVehicle.satVisible}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    ),
                    Text(
                      '${activeVehicle.epv}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    )
                  ],
                )
              )
            ],
          );
        },
      )
    );
  }
}