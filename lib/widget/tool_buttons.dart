import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/model/vehicle.dart';

class ToolButtons extends StatefulWidget {
  const ToolButtons({Key? key}) : super(key: key);

  @override
  State<ToolButtons> createState() => _ToolButtonsState();
}

class _ToolButtonsState extends State<ToolButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<MultiVehicle>(
        builder: (_, multiManager, __) {
          bool isArmed = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.armed) ? true : false; 
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleButton(
                icon: isArmed ? Icons.highlight_off : Icons.check_circle,
                text: isArmed ? "끄기" : "시동",
                submit: () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  if(isArmed) {
                    vehicle.vehicleArm(false);
                  } else {
                    vehicle.vehicleArm(true);
                  }
                },
              ),
              const SizedBox(height: 20),
              CircleButton(
                icon: Icons.flight_takeoff,
                text: "이륙",
                submit: () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleTakeOff(10.0);
                },
              ),
              const SizedBox(height: 20),
              CircleButton(
                icon: Icons.flight_land,
                text: "착륙",
                submit: () {
                  Vehicle? vehicle = multiManager.activeVehicle();
                  if(vehicle == null) return;

                  vehicle.vehicleLand();
                },
              ),
            ],
          );
        },
      )
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? submit; 

  const CircleButton({
    required this.icon,
    required this.text,
    this.submit,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // 버튼의 너비
      margin: const EdgeInsets.all(15),
      child: TextButton(
        onPressed: submit,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // 원형 버튼을 만들기 위한 원의 반지름
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            Colors.grey
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(height: 8), // 아이콘과 텍스트 간의 간격
            Text(
              text,
              style: const TextStyle(
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}