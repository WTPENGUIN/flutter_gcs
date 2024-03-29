import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peachgs_flutter/colors.dart';
import 'package:peachgs_flutter/provider/multivehicle.dart';
import 'package:peachgs_flutter/widget/menu_button.dart';
import 'package:peachgs_flutter/widget/gps_info.dart';
import 'package:peachgs_flutter/widget/flightmode.dart';

class AppToolBar extends StatelessWidget {
  const AppToolBar({Key? key}) : super(key: key);

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
              const AppMenu(),
              const SizedBox(width: 20),
            ],
          ),
        );
      },
    );
  }
}