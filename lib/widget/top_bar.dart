import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/floating_buttons.dart';

Color pBlue  = const Color(0xFF41B6E6);
Color pPeach = const Color(0xffFA828F);

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiVehicle>(
      builder: (_, multiManager, __) {
        bool isArming = (multiManager.activeVehicle() != null && multiManager.activeVehicle()!.armed) ? true : false;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.center,
              colors: [
                isArming ? pBlue : pPeach,
                const Color(0xB3FFFFFF)
              ]
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/image/MainLogo.png', width: 120, height: 40),
              const Spacer(),
              const FloatingButtons(),
              const SizedBox(width: 20)
            ],
          ),
        );
      }
    );
  }
}
