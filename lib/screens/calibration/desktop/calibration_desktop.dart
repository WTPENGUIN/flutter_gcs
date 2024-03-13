import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

import 'package:peachgs_flutter/colors.dart';
import 'package:peachgs_flutter/screens/calibration/accel.dart';
import 'package:peachgs_flutter/screens/calibration/mag.dart';

class CalibrationDesktop extends StatefulWidget {
  const CalibrationDesktop({Key? key}) : super(key: key);

  @override
  State<CalibrationDesktop> createState() => _CalibrationDesktopState();
}

class _CalibrationDesktopState extends State<CalibrationDesktop> {
  final _controller = SidebarXController(extended: true, selectedIndex: 0);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pBlue,
        title: const Text(
          "기체 설정",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            SidebarX(
              controller: _controller,
              theme: SidebarXTheme(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: pBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(color: Colors.white),
                selectedTextStyle: const TextStyle(color: Colors.white),
                itemTextPadding: const EdgeInsets.only(left: 30),
                selectedItemTextPadding: const EdgeInsets.only(left: 30),
                itemDecoration: BoxDecoration(
                  border: Border.all(color: pBlue),
                  borderRadius: BorderRadius.circular(20)
                ),
                selectedItemDecoration: BoxDecoration(
                  color: pPeach,
                  borderRadius: BorderRadius.circular(20),
                ),
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 20,
                ),
                selectedIconTheme: const IconThemeData(
                  color: Colors.white
                ),
                hoverColor: Colors.black54,
                hoverTextStyle: const TextStyle(
                  color: Colors.white
                )
              ),
              extendedTheme: SidebarXTheme(
                width: 200,
                decoration: BoxDecoration(
                  color: pBlue,
                ),
                margin: const EdgeInsets.only(right: 10),
              ),
              items: const [
                SidebarXItem(
                  icon: Icons.sensors,
                  label: '가속도계',
                ),
                SidebarXItem(
                  icon: Icons.explore,
                  label: '지자계',
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: _Screens(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Screens extends StatelessWidget {
  const _Screens({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return const CalibrationAccel();
          case 1:
            return const CalibrationMag();
          default:
            return Text(
              'Not found page',
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }
}