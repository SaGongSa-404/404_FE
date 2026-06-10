import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OS 푸시 알림 권한 요청.
class NotificationPermissionService {
  NotificationPermissionService._();

  static const _legacyPromptedKey = 'os_notification_permission_prompted';
  static bool _requestedThisSession = false;
  static bool _legacyKeyCleared = false;

  /// 이전 구현에서 저장된 1회 플래그가 남아 있으면 제거합니다.
  static Future<void> _clearLegacyPromptedFlag() async {
    if (_legacyKeyCleared) return;
    _legacyKeyCleared = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_legacyPromptedKey)) {
      await prefs.remove(_legacyPromptedKey);
    }
  }

  /// 아직 권한이 없고, 이번 세션에서 요청하지 않았을 때만 true.
  static Future<bool> shouldPrompt() async {
    await _clearLegacyPromptedFlag();
    if (_requestedThisSession) return false;

    final status = await Permission.notification.status;
    if (kDebugMode) {
      debugPrint('[notification] shouldPrompt status=$status');
    }
    return !status.isGranted && !status.isPermanentlyDenied;
  }

  /// OS 알림 권한 다이얼로그를 띄웁니다.
  static Future<void> request() async {
    if (_requestedThisSession) return;

    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied) return;

    _requestedThisSession = true;
    if (kDebugMode) {
      debugPrint('[notification] requesting OS permission...');
    }

    final result = await Permission.notification.request();
    if (kDebugMode) {
      debugPrint('[notification] request result=$result');
    }
  }

  static Future<PermissionStatus> get status => Permission.notification.status;

  static Future<bool> get isGranted async =>
      (await Permission.notification.status).isGranted;

  static Future<bool> get isPermanentlyDenied async =>
      (await Permission.notification.status).isPermanentlyDenied;

  /// OS 알림 권한 다이얼로그를 띄우고 결과를 반환합니다.
  static Future<PermissionStatus> requestPermission() async {
    if (kDebugMode) {
      debugPrint('[notification] requesting OS permission (explicit)...');
    }
    final result = await Permission.notification.request();
    if (kDebugMode) {
      debugPrint('[notification] request result=$result');
    }
    return result;
  }

  /// 기기 설정 앱의 알림 권한 화면으로 이동합니다.
  static Future<bool> openSettings() => openAppSettings();
}
