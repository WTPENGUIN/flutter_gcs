import 'package:flutter/material.dart';

import 'package:peachgs_flutter/screens/home/topbar.dart';
import 'package:peachgs_flutter/screens/home/map_viewer.dart';
import 'package:peachgs_flutter/screens/video/video.dart';

class HomeWindow extends StatelessWidget {
  const HomeWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: const TopBar(),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    color: Colors.transparent,
                    child: const MapViewer(),
                  )
                )
              ]
            ),
            const Positioned(
              bottom: 0,
              child: VideoViewer()
            )
          ]
        )
      )
    );
  }
}
