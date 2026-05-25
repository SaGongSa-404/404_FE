import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/storage/secure_storage.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/services/auth_service.dart';

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
    state = const AsyncLoading();
    // fragment(#) 또는 query(?) 어느 쪽으로 오든 처리
    final fragment = Uri.splitQueryString(uri.fragment);
    final query = uri.queryParameters;
    final accessToken = fragment['access_token'] ?? query['access_token'];
    final refreshToken = fragment['refresh_token'] ?? query['refresh_token'];
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

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } finally {
      await ref.read(secureStorageServiceProvider).clearTokens();
      state = const AsyncData(null);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
