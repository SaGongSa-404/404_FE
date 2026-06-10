import 'package:fe_app/features/notification/services/push_token_service.dart';
import 'package:fe_app/features/notification/services/push_token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그아웃 등 인증 해제 직전에 호출 — Bearer 토큰이 유효할 때 BE에 비활성화 요청.
Future<void> deactivateStoredPushToken(Ref ref) async {
  await deactivateStoredPushTokenWithReader(ref.read);
}

Future<void> deactivateStoredPushTokenWithReader(
  T Function<T>(ProviderListenable<T> provider) read,
) async {
  final token = await PushTokenStorage.read();
  if (token == null || token.isEmpty) return;

  try {
    await read(pushTokenServiceProvider).deactivateToken(token: token);
    await PushTokenStorage.clear();
  } catch (error, stackTrace) {
    // 실패 시 토큰을 지우지 않고 보존해 다음 비활성화 시도에서 재사용한다.
    debugPrint('[push-token] logout deactivate failed: $error\n$stackTrace');
  }
}
