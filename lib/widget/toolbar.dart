import 'package:flutter/material.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:peachgs_flutter/utils/utils.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  State<ToolBar> createState() => _ToolBarStete();
}

class _ToolBarStete extends State<ToolBar> {
  MultiVehicle manager = MultiVehicle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 * scaleSmallDevice(context),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black45, Colors.black26],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
      ),
    );
  }
}