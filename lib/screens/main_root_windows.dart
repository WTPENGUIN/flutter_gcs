import 'package:flutter/material.dart';
import 'package:peachgs_flutter/screens/map_page.dart';

class MainRootWindow extends StatelessWidget {
  const MainRootWindow({ super.key });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: MapPage(),
      ),
    );
  }
}