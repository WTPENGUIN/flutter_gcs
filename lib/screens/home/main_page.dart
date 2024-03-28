import 'package:flutter/material.dart';

import 'package:peachgs_flutter/screens/home/app_toolbar.dart';
import 'package:peachgs_flutter/screens/home/app_body.dart';

class MainRootPage extends StatelessWidget {
  const MainRootPage({Key? key}) : super(key: key);

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
                  child: const AppToolBar(),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    color: Colors.transparent,
                    child: const AppBody(),
                  )
                )
              ]
            )
          ]
        )
      )
    );
  }
}
