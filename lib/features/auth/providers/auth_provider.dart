import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/storage/secure_storage.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/services/auth_service.dart';
import 'package:fe_app/features/profile/models/my_profile.dart';
import 'package:fe_app/features/profile/providers/my_profile_provider.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token == null) return null;
    try {
      return await ref.read(authServiceProvider).getMe();
    } catch (_) {
      await storage.clearTokens();
      return null;
    }
  }

  Future<void> handleCallback(Uri uri) async {
    assert(() {
       debugPrint('[auth] callback received');
       return true;
     }());
    state = const AsyncLoading();
    // fragment(#) 또는 query(?) 어느 쪽으로 오든 처리
    final fragment = Uri.splitQueryString(uri.fragment);
    final query = uri.queryParameters;
    final accessToken = fragment['access_token'] ?? query['access_token'];
    final refreshToken = fragment['refresh_token'] ?? query['refresh_token'];
    if (accessToken == null || refreshToken == null) {
      debugPrint('[auth] tokens missing in callback');
      state = AsyncError(
        Exception('콜백 URL에서 토큰을 찾을 수 없습니다.'),
        StackTrace.current,
      );
      return;
    }
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
    } catch (_) {
      // 표시용 닉네임은 [updateDisplayName] 으로 이미 반영됨
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } finally {
      await ref.read(secureStorageServiceProvider).clearTokens();
      ref.read(myProfileProvider.notifier).reset();
      state = const AsyncData(null);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
