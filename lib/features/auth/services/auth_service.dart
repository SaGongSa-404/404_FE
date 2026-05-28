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

  /// 현재 로그인된 유저 정보 조회
  /// GET /api/auth/me 로 기본 정보를, GET /api/v1/users/me 로 onboardingStatus 를 가져와 병합합니다.
  Future<UserModel> getMe() async {
    final authRes = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    final data = Map<String, dynamic>.from(authRes.data!);

    try {
      final profileRes =
          await _dio.get<Map<String, dynamic>>(ApiEndpoints.usersMe);
      data['onboardingStatus'] = profileRes.data?['onboardingStatus'];
    } on DioException catch (e) {
      // 404: 신규 유저 — 프로필 미생성 → onboardingStatus null 유지
      if (e.response?.statusCode != 404) rethrow;
    }

    return UserModel.fromJson(data);
  }

  /// 로그아웃 (POST /api/logout)
  Future<void> logout() => _dio.post<void>(ApiEndpoints.logout);
}
