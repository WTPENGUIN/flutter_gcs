import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:peachgs_flutter/widget/modal/video_setting_modal.dart';
import 'package:peachgs_flutter/widget/component_widget/outline_text.dart';
import 'package:peachgs_flutter/widget/component_widget/resize_handle_container.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageStete();
}

class _VideoPageStete extends State<VideoPage> {
  // WebRTC
  late final WebViewController _webViewController;

  // RTSP
  late final Player _mediaPlayer = Player();
  late final VideoController _mediaController = VideoController(_mediaPlayer);

  bool play = false; // 재생 상태
  bool isWebView = false;

  // RTSP 혹은 HTTP 아니면 재생 되지 않게
  bool isValidMediaURL(String url) {
    return (url.startsWith('http') || url.startsWith('rtsp'));
  }

  // 모바일인지 여부 판단
  bool isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }

  @override
  void initState() {
    if(isMobile()) {
      _webViewController = WebViewController();
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    super.initState();
  }

  @override
  void dispose() {
    _mediaPlayer.dispose();
    super.dispose();
  }

  Widget readyWidget() {
    return const Center(
      child: OutlineText(
        Text(
          '재생 준비 중....',
          style: TextStyle(color: Colors.white),
        ),
        strokeWidth: 1,
        strokeColor: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void switchURL(String url) async {
    // 데스크톱에서는 웹뷰가 지원되지 않음
    if(!isMobile() && url.startsWith('http')) {
      MotionToast.info(
        title: const Text('정보'),
        description: const Text("윈도우에서는 웹뷰 모드가 지원되지 않습니다."),
        position: MotionToastPosition.bottom,
        animationType: AnimationType.fromBottom,
      ).show(context);
      return;
    }

    // 이전에 재생하던 플레이어 타입에 따라 동작 정지
    if(isWebView) {
      _webViewController.loadRequest(Uri.parse("about:blank"));
    } else {
      await _mediaPlayer.stop();
    }

    // 새로운 url로 전환
    if(url.startsWith('http')) {
      // HTTP로 시작하니 웹뷰로 동작
      isWebView = true;
      _webViewController.loadRequest(Uri.parse(url));
    } else {
      // RTSP로 시작하니 RTSP 플레이어로 동작
      isWebView = false;
      _mediaPlayer.open(
        Media(
          url
        )
      );
    }

    // 재생 중으로 전환
    setState(() {
      play = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResizebleContainerWidget(
      size: const Size(300,200),
      position: ResizeHandlePosition.positionUpperRight,
      child: Stack(
        children: [
          AbsorbPointer(
            child: play ? (isWebView ? WebViewWidget(controller: _webViewController) : Video(controller: _mediaController)) : readyWidget(),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () async {
                var address = await showVideoModal(context);

                // RTSP나 HTTP로 시작하는지 검사
                if(!isValidMediaURL(address)) {
                  if(!mounted) return;
                  if(address.isEmpty) return;
                  MotionToast.error(
                    title: const Text('오류'),
                    description: const Text("URL이 정확하지 않습니다."),
                    position: MotionToastPosition.bottom,
                    animationType: AnimationType.fromBottom,
                  ).show(context);
                }

                // URL 변경을 위한 재생 중지
                setState(() {
                  play = false;
                });
                
                // URL 전환
                switchURL(address);
              },
              icon: const Icon(Icons.settings),
              color: Colors.white,
            ),
          )
        ],
      )
    );
  }
}