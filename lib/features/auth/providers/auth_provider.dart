import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/storage/secure_storage.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/services/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  /// 앱 시작 시 저장된 토큰으로 자동 로그인을 시도합니다.
  @override
  Future<UserModel?> build() async {
    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token == null) return null;

    try {
      return await ref.read(authServiceProvider).getMe();
    } catch (_) {
      // 토큰이 유효하지 않으면 삭제하고 비로그인 처리
      await storage.clearTokens();
      return null;
    }
  }

  /// OAuth 딥링크 콜백을 처리합니다.
  /// URL fragment에서 토큰을 추출 → 저장 → /api/auth/me 호출 → 상태 갱신
  Future<void> handleCallback(Uri uri) async {
    state = const AsyncLoading();

    final params = Uri.splitQueryString(uri.fragment);
    final accessToken  = params['access_token'];
    final refreshToken = params['refresh_token'];

    if (accessToken == null || refreshToken == null) {
      state = AsyncError(
        Exception('콜백 URL에서 토큰을 찾을 수 없습니다.'),
        StackTrace.current,
      );
      return;
    }

    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    try {
      final user = await ref.read(authServiceProvider).getMe();
      state = AsyncData(user);
    } catch (e, st) {
      await storage.clearTokens();
      state = AsyncError(e, st);
    }
  }

  /// 로그아웃: 서버 API 호출 → 토큰 삭제 → 상태 초기화
  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } finally {
      await ref.read(secureStorageServiceProvider).clearTokens();
      state = const AsyncData(null);
    }
  }
}
