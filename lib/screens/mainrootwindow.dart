import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page.dart';
import 'package:peachgs_flutter/widget/floatingbuttons.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: FloatingButtons(),
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(),
          ],
        )
      ),
    );
  }
}