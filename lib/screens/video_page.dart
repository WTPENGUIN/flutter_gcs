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

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageStete();
}

class _VideoPageStete extends State<VideoPage> {
  late final WebViewController _webViewController;                               // WebRTC 뷰어
  late final Player            _mediaPlayer     = Player();                      // RTSP 미디어 플레이어
  late final VideoController   _mediaController = VideoController(_mediaPlayer); // RTSP 미디어 플레이어 컨트롤러

  bool   _play       = false; // 재생 상태 저장
  bool   _isWebView  = false; // 웹뷰 여부
  String _currentUrl = '';    // 현재 재생중인 url

  @override
  void initState() {    
    super.initState();

    // 설정에 저장된 url 가져오기
    _currentUrl = AppConfig().url;

    // 모바일의 경우, 웹뷰 컨트롤러 초기화
    if(_isMobile()) {
      _webViewController = WebViewController();
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted); // 웹뷰 재생을 위해 자바스크립트 허용
    }

  }

  @override
  void dispose() {
    _mediaPlayer.dispose();
    super.dispose();
  }

  // 모바일 환경 검사
  bool _isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }

  // 유효한 미디어 URL인지 검사
  bool _isValidMediaURL(String url) {
    return (url.startsWith('http') || url.startsWith('rtsp'));
  }

  // 재생 중이 아닐 때 표시할 위젯
  Widget _readyWidget() {
    return const Center(
      child: OutlineText(
        strokeWidth: 1,
        strokeColor: Colors.black,
        overflow: TextOverflow.ellipsis,
        child: Text(
          '재생 준비 중...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 재생 중인 미디어 형식에 맞추어 플레이어 위젯 반환
  Widget _playWidget() {
    if(_isWebView) {
      return WebViewWidget(controller: _webViewController);
    } else {
      return Video(controller: _mediaController);
    }
  }

  // 재생 상태 변환
  void _togglePlay() {
    if(_play) {
      // 영상 일시 정지
      if(_isWebView) {
        _webViewController.loadRequest(Uri.parse('about:blank')); // 빈 페이지로 이동
      } else {
        _mediaPlayer.stop();
      }

      setState(() {
        _play = false;
      });
    } else {
      // 영상 재생
      if(_isWebView) {
        _webViewController.loadRequest(Uri.parse(_currentUrl)); // WebRTC 페이지로 이동
      } else {
        // Native 라이브러리를 지원하는 플랫폼에서는 플레이어에 옵션을 설정 할 수 있음.
        // 낮은 대기 옵션 설정
        if(_mediaPlayer.platform is NativePlayer) {
          NativePlayer playerNative = _mediaPlayer.platform as NativePlayer;

          playerNative.setProperty('audio-buffer', '0');
          playerNative.setProperty('vd-lavc-threads', '1');
          playerNative.setProperty('cache-pause', 'no');
          playerNative.setProperty('demuxer-lavf-o-add', 'fflags=+nobuffer');
          playerNative.setProperty('demuxer-lavf-analyzeduration', '0.1');
          playerNative.setProperty('video-sync', 'audio');
          playerNative.setProperty('video-latency-hacks', 'yes');

          playerNative.open(
            Media(_currentUrl)
          );
        } else {
          _mediaPlayer.open(
            Media(_currentUrl)
          );
        }
      }

      setState(() {
        _play = true;
      });
    }
  }

  // 재생 중인 영상 URL 변경
  void _switchURL(String url) async {
    if(_currentUrl == url) return; // 현재 재생중인 URL와 입력한 URL이 같으면 변경하지 않음

    // 데스크톱 버전은 웹뷰 지원하지 않음
    if(!_isMobile() && url.startsWith('http')) {
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
      _play = false;
    });

    // 이전에 재생하던 플레이어 타입에 따라 동작 정지
    if(_isWebView) {
      _webViewController.loadRequest(Uri.parse('about:blank'));
    } else {
      await _mediaPlayer.stop();
    }

    // 새로운 url로 전환
    if(url.startsWith('http')) {
      // HTTP => 웹뷰
      _isWebView = true;
      _webViewController.loadRequest(Uri.parse(url));
    } else {
      // RTSP => 미디어 플레이어
      _isWebView = false;

      // Native 라이브러리를 지원하는 플랫폼에서는 플레이어에 옵션을 설정 할 수 있음.
      // 낮은 대기 옵션 설정
      if(_mediaPlayer.platform is NativePlayer) {
        NativePlayer playerNative = _mediaPlayer.platform as NativePlayer;

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
      } else {
        _mediaPlayer.open(
          Media(url)
        );
      }
    }

    // 새로운 url 저장
    AppConfig().updateStreamUrl(url);
    _currentUrl = url;

    // 플레이어 재생 상태로 전환
    setState(() {
      _play = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ResizebleContainerWidget(
      size: Size(screenSize.width * 0.25, screenSize.height * 0.25),
      position: HandlePosition.positionUpperRight,
      child: Stack(
        children: [
          AbsorbPointer(
            child: _play ? _playWidget() : _readyWidget()
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    var url = await showVideoModal(context);

                    // RTSP나 HTTP로 시작하는지 검사
                    if(!_isValidMediaURL(url)) {
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
                    _switchURL(url);
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
                IconButton(
                  onPressed: () { _togglePlay(); },
                  icon: _play ? const Icon(Icons.pause, color: Colors.white) : const Icon(Icons.play_arrow, color: Colors.white)
                )
              ],
            )
          )
        ],
      )
    );
  }
}