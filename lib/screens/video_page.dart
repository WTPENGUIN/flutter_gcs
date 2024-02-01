import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:peachgs_flutter/utils/utils.dart';
import 'package:peachgs_flutter/widget/resize_handle_container.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageStete();
}

class _VideoPageStete extends State<VideoPage> {
  WebViewController? _webViewController;

  @override
  void initState() {
    if(Platform.isAndroid) {
      _webViewController = WebViewController()
      ..loadRequest(Uri.parse('https://www.youtube.com/')) // TODO : Goto WebRTC Viewer Page
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    super.initState();
  }

  Widget informationWindows() {
    return const Center(
      child: OutlineText(
        Text(
          '윈도우 버전에서는 지원하지 않습니다.',
          style: TextStyle(color: Colors.white),
        ),
        strokeWidth: 1,
        strokeColor: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResizebleContainerWidget(
      size: const Size(400,200),
      child: (Platform.isAndroid ? WebViewWidget(controller: _webViewController!) : informationWindows())
    );
  }
}