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

    if (kDebugMode) {
      debugPrint('[notification] requesting OS permission...');
    }

    try {
      // 1. OS 권한 요청 함수를 먼저 실행하여 대기(await)합니다.
      final result = await Permission.notification.request();

      if (kDebugMode) {
        debugPrint('[notification] request result=$result');
      }

      // 2. 예외 없이 요청 프로세스가 성공적으로 완료된 후에만 세션 플래그를 true로 만듭니다.
      _requestedThisSession = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[notification] 권한 요청 중 시스템 에러 발생: $e');
      }
      // 예외 발생 시 플래그가 true로 변하지 않으므로, 유저가 다시 버튼을 눌러 재시도할 수 있습니다.
      rethrow;
    }
  }

  static Future<PermissionStatus> get status => Permission.notification.status;

  static Future<bool> get isGranted async =>
      (await Permission.notification.status).isGranted;

  static Future<bool> get isPermanentlyDenied async =>
      (await Permission.notification.status).isPermanentlyDenied;

  /// 유저가 명시적으로 알림 설정을 켤 때 OS 권한 다이얼로그를 띄우고 결과를 반환합니다.
  static Future<PermissionStatus> requestPermission() async {
    if (kDebugMode) {
      debugPrint('[notification] requesting OS permission (explicit)...');
    }

    try {
      final result = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint('[notification] request result=$result');
      }
      _requestedThisSession = true;
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[notification] explicit permission request failed: $e');
      }
      rethrow;
    }
  }

  /// 기기 설정 앱의 앱 알림 권한 화면으로 이동합니다.
  static Future<bool> openSettings() => openAppSettings();
}
