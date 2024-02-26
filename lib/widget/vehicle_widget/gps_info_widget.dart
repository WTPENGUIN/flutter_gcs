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
          return (activeVehicle != null) ? const VehicleGPSInfo() : const NotVehicleGPS();
        }
      )
    );
  }
}

class VehicleGPSInfo extends StatelessWidget {
  const VehicleGPSInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: Icon(
              Icons.satellite_alt,
              color: Colors.white,
            )
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Selector<MultiVehicle, String?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.fixType,
                  builder: (context, gpsString, _) {
                    return Text(
                      (gpsString != null) ? gpsString : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    );
                  },
                ),
                Selector<MultiVehicle, int?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.gpsSat,
                  builder: (context, satCount, _) {
                    return Text(
                      (satCount != null) ? 'SAT:$satCount' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 9
                      ),
                    );
                  },
                )
              ],
            )
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Selector<MultiVehicle, double?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.hdop,
                  builder: (context, hdop, _) {
                    return Text(
                      (hdop != null) ? '$hdop' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    );
                  },
                ),
                Selector<MultiVehicle, double?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.vdop,
                  builder: (context, vdop, _) {
                    return Text(
                      (vdop != null) ? '$vdop' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    );
                  },
                )
              ],
            )
          )
        ],
      ),
    );
  }
}

class NotVehicleGPS extends StatelessWidget {
  const NotVehicleGPS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      color: Colors.transparent,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Icon(
              Icons.satellite_alt,
              color: Colors.white,
            )
          ),
          Expanded(
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
        ],
      ),
    );
  }
}