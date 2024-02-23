import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:peachgs_flutter/widget/component_widget/outline_text.dart';
import 'package:peachgs_flutter/widget/component_widget/resize_handle_container.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageStete();
}

class _VideoPageStete extends State<VideoPage> {
  WebViewController? _webViewController;
  late final _mediaPlayer = Player();
  late final _mediaController = VideoController(_mediaPlayer);

  bool isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }

  @override
  void initState() {
    if(isMobile()) {
      _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
      // _webViewController = WebViewController()
      // ..loadRequest(Uri.parse('http://192.168.0.30:8889/cam')) // TODO : Goto WebRTC Viewer Page
      // ..setJavaScriptMode(JavaScriptMode.unrestricted);

      _mediaPlayer.open(
        Media(
          'rtsp://aaaaa:8554/cam'
        )
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _mediaPlayer.dispose();
    super.dispose();
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
      size: const Size(300,200),
      position: ResizeHandlePosition.positionUpperRight,
      child: AbsorbPointer(
        //child: (isMobile() ? WebViewWidget(controller: _webViewController!) : informationWindows()),
        child: (isMobile() ? Video(controller: _mediaController) : informationWindows()),
      ),
    );
  }
}