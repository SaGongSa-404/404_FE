import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/shared/models/pagination.dart';

part 'profile_service.g.dart';

@Riverpod(keepAlive: true)
ProfileService profileService(Ref ref) =>
    ProfileService(ref.watch(apiClientProvider).dio);

class ProfileService {
  const ProfileService(this._dio);

  final Dio _dio;

  static const int defaultPageSize = 20;

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
}
