import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';

class ToolButtons extends StatefulWidget {
  const ToolButtons({
    Key? key
  }) : super(key: key);

  @override
  State<ToolButtons> createState() => _ToolButtonsState();
}

class _ToolButtonsState extends State<ToolButtons> {
  // TODO : 정확한 반응형 UI
  double getPosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if(Platform.isAndroid || Platform.isIOS) {
      if(screenSize.height * 0.15 > 150) {
        return screenSize.height * 0.15;
      } else {
        return 150;
      }
    } else {
      return screenSize.height * 0.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getPosition(context),
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          bool armed = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.armed) ? true : false;
          bool isFlying = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.isFlying) ? true : false;

          return Row(
            children: [
              CustomButton(
                icon: armed ? Icons.highlight_off : Icons.power_settings_new,
                submit: (multiManager.activeVehicle() != null) ?() {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  if(armed) {
                    vehicle.vehicleArm(false);
                  } else {
                    vehicle.vehicleArm(true);
                  }
                } : null,
              ),
              const SizedBox(width: 10),
              CustomButton(
                icon: Icons.file_upload,
                submit: (!isFlying && armed) ? () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleTakeOff(10.0);
                } : null
              ),
              const SizedBox(width: 10),
              CustomButton(
                icon: Icons.download,
                submit: (isFlying && armed) ? () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleLand();
                } : null
              ),
              const SizedBox(width: 10),
              const CustomButton(
                icon: Icons.play_arrow,
                submit: null,
              ),
              const SizedBox(width: 10),
              CustomButton(
                icon: Icons.keyboard_return,
                submit: (isFlying && armed) ? () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleRTL();
                } : null,
              ),
            ],
          );
        },
      )
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final Function()? submit;

  const CustomButton({
    required this.icon,
    required this.submit,
    Key? key
  }) : super(key: key);

  // TODO : 정확한 반응형 UI
  Size getSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    double width = (screenSize.width * 0.08) > 74.7 ? 74.7 : screenSize.width * 0.08;
    double height = (screenSize.height * 0.08) > 56.9 ? 56.9 : screenSize.height * 0.08;

    if(Platform.isAndroid || Platform.isIOS) {
      if(width > 64 && height > 64) {
        return Size(width, height);
      } else {
        return const Size(64, 64);
      }
    } else {
      return Size(width, height);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size buttonSize = getSize(context);

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: ElevatedButton(
        onPressed: submit,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.blue, // <-- Button color
          foregroundColor: Colors.red,  // <-- Splash color
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
