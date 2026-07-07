import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fe_app/core/platform/io_platform.dart';

/// `.env` 값을 읽는 단일 진입점.
abstract final class EnvConfig {
  /// `dotenv.load()` 직후 호출하여 필수 환경변수를 일괄 검증합니다.
  static void validate() {
    final missing = <String>[];
    if (apiBaseUrl.isEmpty) {
      missing.add('BASE_URL or API_BASE_URL');
    }
    if (missing.isNotEmpty) {
      throw StateError(
        '필수 환경변수가 설정되지 않았습니다: ${missing.join(', ')}.\n'
        '.env 파일 또는 --dart-define 를 확인해 주세요.',
      );
    }

    if (kDebugMode && _needsLanHostForPhysicalDevice) {
      final lan = apiLanHost;
      if (lan == null || lan.isEmpty) {
        throw StateError(
          '실기기 + localhost API 사용 시 API_LAN_HOST가 필요합니다.\n'
          'Mac IP 확인: ipconfig getifaddr en0\n'
          '예: API_LAN_HOST=192.168.0.10 (API_BASE_URL은 127.0.0.1·localhost 유지)\n'
          'Cloudflare 등 공개 URL이면 API_LAN_HOST 없이 API_BASE_URL만 설정하세요.',
        );
      }
    }
  }

  static bool get _needsLanHostForPhysicalDevice {
    if (!_useLanHostOnDevice) return false;
    final raw = dotenv.env['API_BASE_URL']?.trim() ?? '';
    return raw.contains('127.0.0.1') || raw.contains('localhost');
  }

  /// 실기기 테스트용 Mac Wi‑Fi IP. USB만으로는 localhost가 Mac을 가리키지 않음.
  static String? get apiLanHost {
    final value = dotenv.env['API_LAN_HOST']?.trim();
    return value != null && value.isNotEmpty ? value : null;
  }

  static String get apiBaseUrl {
    var value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('BASE_URL or API_BASE_URL is required.');
    }
    // Android 에뮬: 10.0.2.2 유지. iOS 시뮬·macOS: localhost 치환.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      value = value.replaceAll('10.0.2.2', '127.0.0.1');
    }
    // iOS·Android 실기기: localhost → API_LAN_HOST
    final lanHost = apiLanHost;
    if (lanHost != null && _useLanHostOnDevice) {
      value = value
          .replaceAll('127.0.0.1', lanHost)
          .replaceAll('localhost', lanHost);
    }
    return value.replaceAll(RegExp(r'/+$'), '');
  }

  static bool get _isIosSimulator {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    return platformEnv('SIMULATOR_DEVICE_NAME') != null;
  }

  static bool get _useLanHostOnDevice {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) return !_isIosSimulator;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final raw = dotenv.env['API_BASE_URL']?.trim() ?? '';
      return !raw.contains('10.0.2.2');
    }
    return false;
  }

  static String? get kakaoNativeAppKey {
    final value = dotenv.env['KAKAO_NATIVE_APP_KEY']?.trim();
    return value != null && value.isNotEmpty ? value : null;
  }

  /// 로컬 개발용 `X-User-Id` (UUID). Bearer가 없을 때 또는 [devAuthMode]가 x_user_id일 때 사용.
  static String? get devUserId {
    final value = dotenv.env['DEV_USER_ID']?.trim();
    return value != null && value.isNotEmpty ? value : null;
  }

  /// `DEV_AUTH_MODE=x_user_id` 이고 [devUserId]가 설정된 로컬 API 테스트 모드.
  static bool get isDevXUserIdAuth =>
      devAuthMode == DevAuthMode.xUserId && devUserId != null;

  /// `bearer`(기본): 저장된 access token 우선, 없으면 [devUserId]로 X-User-Id.
  /// `x_user_id`: /api/v1, /api/dev 호출 시 Bearer 없이 X-User-Id만 사용 (로컬 테스트).
  static DevAuthMode get devAuthMode {
    final raw = dotenv.env['DEV_AUTH_MODE']?.trim().toLowerCase();
    return switch (raw) {
      'x_user_id' || 'x-user-id' => DevAuthMode.xUserId,
      _ => DevAuthMode.bearer,
    };
  }

  /// Firebase(FCM) Dart 초기화용. 모두 설정되어 있을 때만 [isFirebaseConfigured]가 true.
  static bool get isFirebaseConfigured =>
      firebaseApiKey != null &&
      firebaseAppId != null &&
      firebaseMessagingSenderId != null &&
      firebaseProjectId != null;

  static String? get firebaseApiKey => _optionalEnv('FIREBASE_API_KEY');
  static String? get firebaseAppId => _optionalEnv('FIREBASE_APP_ID');
  static String? get firebaseMessagingSenderId =>
      _optionalEnv('FIREBASE_MESSAGING_SENDER_ID');
  static String? get firebaseProjectId => _optionalEnv('FIREBASE_PROJECT_ID');
  static String? get firebaseStorageBucket =>
      _optionalEnv('FIREBASE_STORAGE_BUCKET');
  static String? get firebaseIosBundleId =>
      _optionalEnv('FIREBASE_IOS_BUNDLE_ID');

  static String? _optionalEnv(String key) {
    final value = dotenv.env[key]?.trim();
    return value != null && value.isNotEmpty ? value : null;
  }
}

enum DevAuthMode {
  bearer,
  xUserId,
}
