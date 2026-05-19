import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env` 값을 읽는 단일 진입점.
abstract final class EnvConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']?.trim() ?? '';

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
