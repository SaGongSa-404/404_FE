import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/network/session_expiration.dart';
import 'package:fe_app/core/storage/secure_storage.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/services/auth_service.dart';
import 'package:fe_app/features/notification/services/push_token_lifecycle.dart';
import 'package:fe_app/features/profile/models/my_profile.dart';
import 'package:fe_app/features/profile/providers/my_profile_provider.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';
import 'package:fe_app/features/auth/utils/oauth_callback_uri.dart';
import 'package:fe_app/features/auth/utils/oauth_launch.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    void handleSessionExpired() {
      unawaited(sessionExpired());
    }

    SessionExpiration.onExpired = handleSessionExpired;
    ref.onDispose(() {
      if (SessionExpiration.onExpired == handleSessionExpired) {
        SessionExpiration.onExpired = null;
      }
    });

    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token == null && !EnvConfig.isDevXUserIdAuth) return null;
    try {
      return await ref.read(authServiceProvider).getMe();
    } catch (_) {
      if (token != null) await storage.clearTokens();
      return null;
    }
  }

  Future<void> sessionExpired() async {
    await ref.read(secureStorageServiceProvider).clearTokens();
    ref.read(myProfileProvider.notifier).reset();
    state = const AsyncData(null);
  }

  void resetToLoggedOut() {
    state = const AsyncData(null);
  }

  Future<bool> launchOAuthSignIn(String provider) async {
    if (state.hasError) resetToLoggedOut();

    final base = Uri.parse(EnvConfig.apiBaseUrl);
    final url = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/oauth2/authorization/$provider',
      queryParameters: {'redirect_uri': kOAuthRedirectUri},
    );

    try {
      return await launchUrl(url, mode: oauthLaunchMode());
    } catch (_) {
      return false;
    }
  }

  Future<void> handleCallback(Uri uri) async {
    if (kDebugMode) {
      debugPrint('[auth] callback: ${describeOAuthCallbackUri(uri)}');
    }
    state = const AsyncLoading();
    final params = readOAuthCallbackParams(uri);
    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      debugPrint('[auth] tokens missing in callback (params=${params.keys})');
      state = AsyncError(
        Exception('콜백 URL에서 토큰을 찾을 수 없습니다.'),
        StackTrace.current,
      );
      return;
    }
    await _persistTokensAndLoadUser(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// 로그인 화면 로고 N회 탭 등 숨겨진 진입점 — 심사용 고정 계정 토큰 발급
  Future<void> signInWithReviewerToken() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      final tokens = await ref.read(authServiceProvider).issueReviewerToken();
      await _persistTokensAndLoadUser(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _persistTokensAndLoadUser({
    required String accessToken,
    required String refreshToken,
  }) async {
    final storage = ref.read(secureStorageServiceProvider);
    debugPrint('[auth] saving tokens');
    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    try {
      debugPrint('[auth] fetching /api/auth/me');
      final user = await ref.read(authServiceProvider).getMe();
      debugPrint('[auth] /api/auth/me success: onboardingStatus=${user.onboardingStatus}');
      state = AsyncData(user);
    } catch (e, st) {
      debugPrint('[auth] /api/auth/me failed: $e\n$st');
      await storage.clearTokens();
      state = AsyncError(e, st);
    }
  }

  void updateDisplayName(String name) {
    final user = state.valueOrNull;
    if (user == null) return;
    state = AsyncData(user.copyWith(name: name));
  }

  void markOnboardingCompleted() {
    final user = state.valueOrNull;
    if (user == null) return;
    state = AsyncData(user.copyWith(onboardingStatus: 'COMPLETED'));
  }

  /// 온보딩 완료 후 auth 상태를 동기화합니다. dev user는 `/api/auth/me` 없이 프로필로 hydrate 합니다.
  Future<bool> syncOnboardingCompleted() async {
    if (state.valueOrNull == null && EnvConfig.devUserId != null) {
      await _hydrateFromDevProfile();
    }

    markOnboardingCompleted();
    await refreshFromServer();

    if (_hasCompletedOnboarding) return true;

    if (EnvConfig.devUserId != null) {
      await _hydrateFromDevProfile();
      markOnboardingCompleted();
    }

    return _hasCompletedOnboarding;
  }

  bool get _hasCompletedOnboarding =>
      state.valueOrNull?.onboardingStatus == 'COMPLETED';

  Future<void> _hydrateFromDevProfile() async {
    try {
      final profile = await ref.read(profileServiceProvider).getMyProfile();
      if (!profile.isValid) return;
      state = AsyncData(_userFromProfile(profile));
    } catch (_) {}
  }

  UserModel _userFromProfile(MyProfile profile) => UserModel(
        userId: profile.id,
        provider: profile.provider.isNotEmpty ? profile.provider : 'dev',
        providerUserId: profile.id,
        name: profile.nickname,
        principalName: profile.nickname,
        authorities: const [],
        onboardingStatus: profile.onboardingStatus,
      );

  Future<void> refreshFromServer() async {
    try {
      final user = await ref.read(authServiceProvider).getMe();
      state = AsyncData(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await sessionExpired();
      }
    } catch (_) {
      // 표시용 닉네임은 [updateDisplayName] 으로 이미 반영됨
    }
  }

  Future<void> logout() async {
    try {
      await deactivateStoredPushToken(ref);
      await ref.read(authServiceProvider).logout();
    } finally {
      await ref.read(secureStorageServiceProvider).clearTokens();
      ref.read(myProfileProvider.notifier).reset();
      state = const AsyncData(null);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
