import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page.dart';
import 'package:peachgs_flutter/widget/floating_buttons.dart';
import 'package:peachgs_flutter/widget/vehicle_information.dart';
import 'package:peachgs_flutter/screens/video_page.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: FloatingButtons(),
      body: SafeArea(
        child: Stack(
          children: [
            MapWindow(),
            Positioned(
              top: 0,
              child: VehicleInfo()
            ),
            Positioned(
              bottom: 0,
              child: VideoPage()
            )
          ],
        )
      ),
    );
  }
}