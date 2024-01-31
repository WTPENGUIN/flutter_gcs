import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page.dart';
import 'package:peachgs_flutter/widget/floating_buttons.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const FloatingButtons(),
      body: SafeArea(
        child: Stack(
          children: [
            const MapWidget(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                width: 300,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0x99808080)
                )
              ),
            )
          ],
        )
      ),
    );
  }
}