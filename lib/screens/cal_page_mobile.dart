import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

import 'package:peachgs_flutter/widget/calibration/cal_accel.dart';
import 'package:peachgs_flutter/widget/calibration/cal_mag.dart';

const canvasColor = Color(0xFF41B6E6);
const itemColor   = Color(0xffFA828F);
const white       = Colors.white;

class VehicleCalMobile extends StatefulWidget {
  const VehicleCalMobile({Key? key}) : super(key: key);

  @override
  State<VehicleCalMobile> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VehicleCalMobile> {
  final _controller = SidebarXController(extended: true, selectedIndex: 0);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarX(
        controller: _controller,
        theme: SidebarXTheme(
          height: MediaQuery.of(context).size.height * 0.90,
          margin: const EdgeInsets.only(top: 80),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(20)
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
            borderRadius: BorderRadius.circular(20)
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 20
          ),
          selectedIconTheme: const IconThemeData(
            color: Colors.white,
          ),
          hoverColor: Colors.black54,
          hoverTextStyle: const TextStyle(
            color: Colors.white
          )
        ),
        extendedTheme: SidebarXTheme(
          width: 200,
          height: MediaQuery.of(context).size.height * 0.90,
          margin: const EdgeInsets.only(right: 10, top: 80),
          decoration: const BoxDecoration(
            color: canvasColor
          ),
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
      appBar: AppBar(
        backgroundColor: canvasColor,
        title: const Text(
          "기체 설정",
          style: TextStyle(
            color: Colors.white
          )
        ),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
          )
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (_) {
          context.pop();
        },
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: _Screens(controller: _controller),
                )
              )
            ],
          ),
        ),
      )
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