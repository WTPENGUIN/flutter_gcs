import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/widget/ui/floating_buttons.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/gps_info_widget.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/remote_id_info.dart';
import 'package:peachgs_flutter/widget/vehicle_widget/flight_mode_menu.dart';

Color pBlue  = const Color(0xFF41B6E6);
Color pPeach = const Color(0xffFA828F);

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MultiVehicle, bool?>(
      selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.armed,
      builder: (context, isArming, _) {
        return Container(
          height: 56, // 안드로이드 기본 상단바의 높이,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.center,
              colors: [
                (isArming != null && isArming) ? pBlue : pPeach,
                const Color(0xB3FFFFFF)
              ]
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/image/MainLogo.png', fit: BoxFit.fill),
              const SizedBox(width: 20),
              const GPSWidget(),
              const FlightModeMenu(),
              const Spacer(),
              const RemoteIdInfo(),
              const SizedBox(width: 20),
              const FloatingButtons(),
              const SizedBox(width: 20),
            ],
          ),
        );
      },
    );
  }
}