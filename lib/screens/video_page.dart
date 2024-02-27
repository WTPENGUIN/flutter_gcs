import 'dart:io';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:peachgs_flutter/model/app_setting.dart';
import 'package:peachgs_flutter/widget/modal/video_setting_modal.dart';
import 'package:peachgs_flutter/widget/component_widget/outline_text.dart';
import 'package:peachgs_flutter/widget/component_widget/resize_handle_container.dart';

// TODO : 이전에 설정한 URL 불러와서 자동 비디오 스트리밍 실행
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

  bool play = false;      // 재생 상태 저장
  bool isWebView = false; // 웹뷰 여부
  String currentUrl = ''; // 현재 재생중인 url

  bool isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }

  // RTSP 혹은 HTTP외에 허용하지 않음
  bool isValidMediaURL(String url) {
    return (url.startsWith('http') || url.startsWith('rtsp'));
  }

  @override
  void initState() {    
    super.initState();

    if(isMobile()) {
      _webViewController = WebViewController();
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted); // 웹뷰 재생을 위해 자바스크립트 허용
    }
  }

  @override
  void dispose() {
    _mediaPlayer.dispose();
    super.dispose();
  }

  // 재생 중이 아닐 때 표시할 위젯
  Widget readyWidget() {
    return const Center(
      child: OutlineText(
        Text(
          '재생 준비 중...',
          style: TextStyle(color: Colors.white),
        ),
        strokeWidth: 1,
        strokeColor: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // 재생 중인 미디어 형식에 맞추어 플레이어 위젯 반환
  Widget playWidget() {
    return isWebView ? WebViewWidget(controller: _webViewController) : Video(controller: _mediaController);
  }

  void switchURL(String url) async {
    // 현재 재생중인 URL와 입력한 URL이 같으면 변경하지 않음
    if(currentUrl == url) return;

    // 데스크톱 버전은 웹뷰 지원하지 않음
    if(!isMobile() && url.startsWith('http')) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: '윈도우에서는 웹뷰가 지원되지 않습니다.',
        ),
        snackBarPosition: SnackBarPosition.top
      );
      return;
    }
    
    // URL 변경을 위한 재생 중지
    setState(() {
      play = false;
    });

    // 이전에 재생하던 플레이어 타입에 따라 동작 정지
    if(isWebView) {
      _webViewController.loadRequest(Uri.parse('about:blank'));
    } else {
      await _mediaPlayer.stop();
    }

    // 새로운 url로 전환
    if(url.startsWith('http')) {
      // HTTP => 웹뷰
      isWebView = true;
      _webViewController.loadRequest(Uri.parse(url));
    } else {
      // RTSP => 미디어 플레이어
      isWebView = false;

      if(_mediaPlayer.platform is NativePlayer) {
        NativePlayer playerNative = _mediaPlayer.platform as NativePlayer;

        // 낮은 대기 옵션
        playerNative.setProperty('audio-buffer', '0');
        playerNative.setProperty('vd-lavc-threads', '1');
        playerNative.setProperty('cache-pause', 'no');
        playerNative.setProperty('demuxer-lavf-o-add', 'fflags=+nobuffer');
        playerNative.setProperty('demuxer-lavf-analyzeduration', '0.1');
        playerNative.setProperty('video-sync', 'audio');
        playerNative.setProperty('video-latency-hacks', 'yes');

        playerNative.open(
          Media(url)
        );
      }
    }

    // 새로운 url 저장
    AppConfig().updateStreamUrl(url);
    currentUrl = url;

    // 플레이어 재생 상태로 전환
    setState(() {
      play = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ResizebleContainerWidget(
      size: Size(screenSize.width * 0.25, screenSize.height * 0.25),
      position: ResizeHandlePosition.positionUpperRight,
      child: Stack(
        children: [
          AbsorbPointer(
            child: play ? playWidget() : readyWidget(),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TODO : 재생, 정지 버튼 구현
                IconButton(
                  onPressed: () async {
                    var url = await showVideoModal(context);

                    // RTSP나 HTTP로 시작하는지 검사
                    if(!isValidMediaURL(url)) {
                      if(!mounted || url.isEmpty) return;
                      showTopSnackBar(
                        Overlay.of(context),
                        const CustomSnackBar.error(
                          message: 'URL은 http와 rtsp만 지원합니다.',
                        ),
                        snackBarPosition: SnackBarPosition.top
                      );
                      return;
                    }
                
                    // URL 전환
                    switchURL(url);
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                )
              ],
            )
          )
        ],
      )
    );
  }
}