import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppSetting {
  int    _mavid     = 250;
  String _streamUrl = '';

  int    get id  => _mavid;
  String get url => _streamUrl;

  // 파일 이름
  static const String _fileName = 'PeachAppConfig.json';

  // AppConfig 클래스는 싱글톤 클래스로 관리
  static AppSetting? _instance;
  AppSetting._privateConstructor() {
    // 앱 시작 시 설정 로드
    loadAppConfig();
  }
  factory AppSetting() => _instance ??= AppSetting._privateConstructor();

  // 설정을 로드하는 메서드
  Future<void> loadAppConfig() async {
    try {
      // 어플리케이션 내부 저장소 경로 가져오기
      Directory internalStorage = await getApplicationDocumentsDirectory();
      String    filePath        = '${internalStorage.path}/$_fileName';

      File file = File(filePath);
      if(await file.exists()) {
        // 파일이 존재하는 경우 파일 내용 읽기
        String content = await file.readAsString();

        Map<String, dynamic> jsonMap = json.decode(content);
        _mavid     = jsonMap['mavid']     ?? 200;
        _streamUrl = jsonMap['video_url'] ?? '';
      } else {
        // 파일이 존재하지 않는 경우 기본 설정 저장
        await _saveAppConfig();
      }
    } catch (e) {
      Logger().e('Error while reading app config: $e');
    }
  }

  // 설정을 저장하는 메서드
  Future<void> _saveAppConfig() async {
    try {
      // 어플리케이션 내부 저장소 경로 가져오기
      Directory internalStorage = await getApplicationDocumentsDirectory();
      String    filePath        = '${internalStorage.path}/$_fileName';
      
      // 설정을 JSON으로 직렬화하여 파일에 쓰기
      File file = File(filePath);
      await file.writeAsString(
        json.encode({
          'mavid'    : _mavid,
          'video_url': _streamUrl
        })
      );
    } catch (e) {
      Logger().e('Error while saving app config: $e');
    }
  }

  // 설정 업데이트 메서드
  void updateConfig(int id, String url) {
    _mavid     = id;
    _streamUrl = url;
    _saveAppConfig();
  }

  // Mavlink ID 업데이트 메서드
  void updateMavId(int id) {
    _mavid = id;
    _saveAppConfig();
  }

  // Video Streaming URL 업데이트 메서드
  void updateStreamUrl(String url) {
    _streamUrl = url;
    _saveAppConfig();
  }
}