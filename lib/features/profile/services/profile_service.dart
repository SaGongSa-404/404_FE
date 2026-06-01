import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/profile/models/my_profile.dart';
import 'package:fe_app/features/profile/models/notification_settings.dart';
import 'package:fe_app/features/profile/utils/profile_json.dart';
import 'package:fe_app/shared/models/pagination.dart';

part 'profile_service.g.dart';

@Riverpod(keepAlive: true)
ProfileService profileService(Ref ref) =>
    ProfileService(ref.watch(apiClientProvider).dio);

class ProfileService {
  const ProfileService(this._dio);

  final Dio _dio;

  static const int defaultPageSize = 20;

  /// GET /api/v1/users/me — 내 프로필 요약 조회.
  Future<MyProfile> getMyProfile() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.usersMe);
    return _parseMyProfile(res.data);
  }

  /// PATCH /api/v1/users/me/profile — 닉네임 수정.
  Future<MyProfile> updateProfile({required String nickname}) async {
    final res = await _dio.patch<dynamic>(
      ApiEndpoints.usersMeProfile,
      data: {'nickname': nickname},
    );
    return _parseMyProfile(res.data);
  }

  MyProfile _parseMyProfile(Object? data) {
    final profile = MyProfile.fromJson(parseProfileJsonMap(data));
    if (!profile.isValid) {
      throw const ApiException(
        message: '프로필 응답 형식이 올바르지 않습니다.',
      );
    }
    return profile;
  }

  /// GET /api/v1/users/me/posts — 내가 작성한 소셜 게시글 (cursor).
  Future<CursorPage<FeedPost>> listMyPosts({
    String? cursor,
    int size = defaultPageSize,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.usersMePosts,
      queryParameters: {
        'size': size,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return CursorPage.fromJson(
      requireJsonMap(res.data),
      'posts',
      FeedPost.fromJson,
    );
  }

  /// GET /api/v1/users/me/notification-settings — 알림 수신 설정 조회.
  Future<NotificationSettings> getNotificationSettings() async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.usersMeNotificationSettings,
    );
    return NotificationSettings.fromJson(parseProfileJsonMap(res.data));
  }

  /// PATCH /api/v1/users/me/notification-settings — 알림 수신 설정 수정.
  Future<NotificationSettings> updateNotificationSettings({
    required bool notificationEnabled,
  }) async {
    final res = await _dio.patch<dynamic>(
      ApiEndpoints.usersMeNotificationSettings,
      data: {'notificationEnabled': notificationEnabled},
    );
    return NotificationSettings.fromJson(parseProfileJsonMap(res.data));
  }
}
