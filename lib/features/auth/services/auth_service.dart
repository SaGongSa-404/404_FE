import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/profile/models/my_profile.dart';
import 'package:fe_app/features/profile/utils/profile_json.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) =>
    AuthService(ref.watch(apiClientProvider).dio);

class AuthService {
  const AuthService(this._dio);
  final Dio _dio;

  /// 현재 로그인된 유저 정보 조회
  /// GET /api/auth/me 로 기본 정보를, GET /api/v1/users/me 로 onboardingStatus 를 가져와 병합합니다.
  /// [EnvConfig.isDevXUserIdAuth] 이면 Bearer 없이 `GET /api/v1/users/me` 만 사용합니다.
  Future<UserModel> getMe() async {
    if (EnvConfig.isDevXUserIdAuth) {
      return getMeViaDevUserId();
    }

    final authRes = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    final data = Map<String, dynamic>.from(authRes.data!);

    try {
      final profileRes = await _dio.get<dynamic>(ApiEndpoints.usersMe);
      final profile = parseProfileJsonMap(profileRes.data);
      data['onboardingStatus'] = profile['onboardingStatus'];
      final nickname = profile['nickname']?.toString();
      if (nickname != null && nickname.isNotEmpty) {
        data['name'] = nickname;
      }
    } on DioException catch (e) {
      // 404: 신규 유저 — 프로필 미생성 → onboardingStatus null 유지
      if (e.response?.statusCode != 404) rethrow;
    } catch (_) {
      // users/me 병합 실패 시 auth/me 결과만 사용
    }

    return UserModel.fromJson(data);
  }

  /// 로컬 `X-User-Id` 세션 — 프로필이 없으면(404) 온보딩용 최소 유저를 반환합니다.
  Future<UserModel> getMeViaDevUserId() async {
    final devId = EnvConfig.devUserId!;
    try {
      final profileRes = await _dio.get<dynamic>(ApiEndpoints.usersMe);
      final profile = MyProfile.fromJson(parseProfileJsonMap(profileRes.data));
      if (profile.isValid) {
        return _userModelFromProfile(profile);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }

    return UserModel(
      userId: devId,
      provider: 'dev',
      providerUserId: devId,
      name: 'Developer',
      principalName: devId,
      authorities: const [],
      onboardingStatus: null,
    );
  }

  static UserModel _userModelFromProfile(MyProfile profile) {
    return UserModel(
      userId: profile.id,
      provider: profile.provider.isNotEmpty ? profile.provider : 'dev',
      providerUserId: profile.id,
      name: profile.nickname,
      principalName: profile.nickname,
      authorities: const [],
      onboardingStatus: profile.onboardingStatus,
    );
  }

  /// 로그아웃 (POST /api/logout)
  Future<void> logout() => _dio.post<void>(ApiEndpoints.logout);
}
