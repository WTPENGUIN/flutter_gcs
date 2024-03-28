import 'dart:io';
import 'package:flutter/material.dart';

import 'package:peachgs_flutter/screens/desktop/desktop_body.dart';
import 'package:peachgs_flutter/screens/mobile/mobile_body.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  bool _isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }

  @override
  Widget build(BuildContext context) {
    return _isMobile() ? const MobileBody() : const DesktopBody();
  }
}
