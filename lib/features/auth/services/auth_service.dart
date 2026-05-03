import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/auth/models/user.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) =>
    AuthService(ref.watch(apiClientProvider).dio);

class AuthService {
  const AuthService(this._dio);
  final Dio _dio;

  /// 현재 로그인된 유저 정보 조회 (GET /api/auth/me)
  Future<UserModel> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserModel.fromJson(res.data!);
  }

  /// 로그아웃 (POST /api/logout)
  Future<void> logout() => _dio.post<void>(ApiEndpoints.logout);
}
