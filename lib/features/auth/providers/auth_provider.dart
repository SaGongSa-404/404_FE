import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/storage/secure_storage.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/services/auth_service.dart';
import 'package:fe_app/features/auth/utils/oauth_callback_uri.dart';
import 'package:fe_app/features/profile/providers/my_profile_provider.dart';

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

  void resetToLoggedOut() {
    state = const AsyncData(null);
  }

  Future<void> handleCallback(Uri uri) async {
    debugPrint('[auth] callback: $uri');
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
