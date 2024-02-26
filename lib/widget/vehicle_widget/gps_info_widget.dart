import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/component_widget/overlayportal_drop_menu.dart';

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

class VehicleGPSInfo extends StatefulWidget {
  const VehicleGPSInfo({Key? key}) : super(key: key);

  @override
  State<VehicleGPSInfo> createState() => _VehicleGPSInfoState();
}

class _VehicleGPSInfoState extends State<VehicleGPSInfo> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayFlexDropDown(
      controller: _controller,
      buttonBuilder: (BuildContext context, Function() onTap) {
        return Selector<MultiVehicle, String?>(
          selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.fixType,
          builder: (context, fixString, _) {
            // 현재 선택된 기체의 GPS 픽스 타입을 가져와서 위젯을 빌드
            return GpsButtonWidget(
              width: 130,
              onTap: onTap,
              fixString: '$fixString'
            );
          },
        );
      },
      menuBuilder: (BuildContext context, double? width) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
            // 현재 선택된 기체의 GPS 정보를 가져와서 위젯을 빌드
            child: GPSModeButton(
            width: 130,
            onItemTap: () {
              _controller.hide();
            },
          ),
        );
      }
    );
  }
}

class GpsButtonWidget extends StatelessWidget {
  const GpsButtonWidget({
    super.key,
    required this.fixString,
    this.height = 48,
    this.width,
    this.onTap,
    this.child,
  });

  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final Widget? child;
  final String fixString;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.satellite_alt,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 2,
                    child: Text(
                    fixString,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                    ),
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}

class GPSModeButton extends StatelessWidget {
  const GPSModeButton({
    super.key,
    this.width,
    required this.onItemTap,
  });

  final double? width;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.5,
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 32,
            offset: Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 4,
                child: Text(
                  'Count : ',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Selector<MultiVehicle, int?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.gpsSat,
                  builder: (context, satCount, _) {
                    return Text(
                      (satCount != null) ? '$satCount' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      )
                    );
                  }
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'HDOP : ',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Selector<MultiVehicle, double?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.hdop,
                  builder: (context, hdop, _) {
                    return Text(
                      (hdop != null) ? '$hdop' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      )
                    );
                  }
                )
              )
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'VDOP : ',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Selector<MultiVehicle, double?>(
                  selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.vdop,
                  builder: (context, vdop, _) {
                    return Text(
                      (vdop != null) ? '$vdop' : '',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      )
                    );
                  }
                )
              )
            ],
          )
        ]
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