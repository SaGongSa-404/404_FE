import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  }

  static String get apiBaseUrl {
    var value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('BASE_URL or API_BASE_URL is required.');
    }
    // Android 에뮬 전용 10.0.2.2 → iOS 시뮬·macOS 에서는 localhost 로 치환
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      value = value.replaceAll('10.0.2.2', '127.0.0.1');
    }
    return value.replaceAll(RegExp(r'/+$'), '');
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

  /// `bearer`(기본): 저장된 access token 우선, 없으면 [devUserId]로 X-User-Id.
  /// `x_user_id`: /api/v1, /api/dev 호출 시 Bearer 없이 X-User-Id만 사용 (로컬 테스트).
  static DevAuthMode get devAuthMode {
    final raw = dotenv.env['DEV_AUTH_MODE']?.trim().toLowerCase();
    return switch (raw) {
      'x_user_id' || 'x-user-id' => DevAuthMode.xUserId,
      _ => DevAuthMode.bearer,
    };
  }
}

enum DevAuthMode {
  bearer,
  xUserId,
}
