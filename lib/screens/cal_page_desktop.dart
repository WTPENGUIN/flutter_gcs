import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

import 'package:peachgs_flutter/widget/calibration/cal_accel.dart';
import 'package:peachgs_flutter/widget/calibration/cal_mag.dart';

const canvasColor = Color(0xFF41B6E6);
const itemColor   = Color(0xffFA828F);
const white = Colors.white;

class VehicleCalDesktop extends StatefulWidget {
  const VehicleCalDesktop({Key? key}) : super(key: key);

  @override
  State<VehicleCalDesktop> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VehicleCalDesktop> {
  final _controller = SidebarXController(extended: true, selectedIndex: 0);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: const Text("기체 설정"),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
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
                  color: canvasColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(color: Colors.white),
                selectedTextStyle: const TextStyle(color: Colors.white),
                itemTextPadding: const EdgeInsets.only(left: 30),
                selectedItemTextPadding: const EdgeInsets.only(left: 30),
                itemDecoration: BoxDecoration(
                  border: Border.all(color: canvasColor),
                  borderRadius: BorderRadius.circular(20)
                ),
                selectedItemDecoration: BoxDecoration(
                  color: itemColor,
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
              extendedTheme: const SidebarXTheme(
                width: 200,
                decoration: BoxDecoration(
                  color: canvasColor,
                ),
                margin: EdgeInsets.only(right: 10),
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
                child: _ScreensExample(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
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