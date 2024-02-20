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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.transparent,
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          bool armed = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.armed) ? true : false;
          bool isFlying = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.isFlying) ? true : false;

          return Row(
            children: [
              ToolButton(
                icon: armed ? Icons.highlight_off : Icons.power_settings_new,
                color: (multiManager.activeVehicle() != null) ? Colors.blue : Colors.grey,
                submit: (multiManager.activeVehicle() != null) ? () {
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
              ToolButton(
                icon: Icons.file_upload,
                color: (!isFlying && armed) ? Colors.blue : Colors.grey,
                submit: (!isFlying && armed) ? () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleTakeOff(10.0);
                } : null
              ),
              const SizedBox(width: 10),
              ToolButton(
                icon: Icons.download,
                color: (isFlying && armed) ? Colors.blue : Colors.grey,
                submit: (isFlying && armed) ? () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleLand();
                } : null
              ),
              const SizedBox(width: 10),
              ToolButton(
                icon: Icons.keyboard_return,
                color: (isFlying && armed) ? Colors.blue : Colors.grey,
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

class ToolButton extends StatelessWidget {
  final IconData icon;
  final Function()? submit;
  final Color color;

  const ToolButton({
    required this.icon,
    required this.submit,
    required this.color,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: color
      ),
      child: IconButton(
        onPressed: submit,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
