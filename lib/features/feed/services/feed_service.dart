import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/feed/models/create_comment_request.dart';
import 'package:fe_app/features/feed/models/create_post_request.dart';
import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/report_request.dart';
import 'package:fe_app/features/feed/models/update_post_request.dart';
import 'package:fe_app/features/feed/models/vote_request.dart';
import 'package:fe_app/features/feed/models/vote_response.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:fe_app/shared/models/pagination.dart';

part 'feed_service.g.dart';

@Riverpod(keepAlive: true)
FeedService feedService(Ref ref) =>
    FeedService(ref.watch(apiClientProvider).dio);

class FeedService {
  const FeedService(this._dio);

  final Dio _dio;

  static const int defaultPageSize = 20;
  static const int minPageSize = 1;
  static const int maxPageSize = 100;

  Future<CursorPage<FeedPost>> listPosts({
    String? cursor,
    int size = defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    final boundedSize = size.clamp(minPageSize, maxPageSize);
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.socialPosts,
      queryParameters: {
        'size': boundedSize,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
      cancelToken: cancelToken,
    );
    return CursorPage.fromJson(
      requireJsonMap(res.data),
      'posts',
      FeedPost.fromJson,
    );
  }

  Future<FeedPost> getPost(String postId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.socialPost(postId),
    );
    return FeedPost.fromJson(requireJsonMap(res.data));
  }

  Future<FeedPost> createPost(CreatePostRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.socialPosts,
      data: request.toApiJson(),
    );
    return FeedPost.fromJson(requireJsonMap(res.data));
  }

  Future<FeedPost> updatePost(String postId, UpdatePostRequest request) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.socialPost(postId),
      data: request.toJson(),
    );
    return FeedPost.fromJson(requireJsonMap(res.data));
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete<void>(ApiEndpoints.socialPost(postId));
  }

  Future<VoteResponse> votePost(String postId, VoteType voteType) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.socialPostVotes(postId),
      data: VoteRequest(voteType: voteType).toJson(),
    );
    return VoteResponse.fromJson(requireJsonMap(res.data));
  }

  /// 멀티파트로 이미지 업로드 후 서버 저장 경로(URL)을 반환합니다.
  ///
  /// 웹/네이티브 공통으로 동작하도록 파일 경로 대신 바이트로 전송합니다.
  /// (모바일은 `XFile.readAsBytes()`, 웹은 picker가 제공하는 바이트를 그대로 전달)
  Future<String> uploadImage(
    List<int> bytes, {
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.socialPostUploads,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = requireJsonMap(res.data);
    final url = data['url'];
    if (url is! String || url.isEmpty) {
      throw StateError('업로드 응답에 url이 없습니다.');
    }
    return url;
  }

  Future<OffsetPage<FeedComment>> listComments(
    String postId, {
    int page = 1,
    int size = defaultPageSize,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.socialPostComments(postId),
      queryParameters: {'page': page, 'size': size},
    );
    final json = requireJsonMap(res.data);
    final rawItems = json['comments'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => FeedComment.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = (json['total'] as num?)?.toInt() ?? items.length;
    return OffsetPage(items: items, total: total, page: page, size: size);
  }

  Future<FeedComment> createComment(String postId, String body) async {
    final request = CreateCommentRequest.fromCompose(body: body);
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.socialPostComments(postId),
      data: request.toApiJson(),
    );
    return FeedComment.fromJson(requireJsonMap(res.data));
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _dio.delete<void>(
      ApiEndpoints.socialPostComment(postId, commentId),
    );
  }

  Future<void> reportPost(
    String postId, {
    required String category,
    String? reason,
  }) async {
    final request = ReportRequest.fromSubmission(
      category: category,
      reason: reason,
    );
    await _dio.post<void>(
      ApiEndpoints.socialPostReports(postId),
      data: request.toApiJson(),
    );
  }

  Future<void> reportComment(
    String postId,
    String commentId, {
    required String category,
    String? reason,
  }) async {
    final request = ReportRequest.fromSubmission(
      category: category,
      reason: reason,
    );
    await _dio.post<void>(
      ApiEndpoints.socialPostCommentReports(postId, commentId),
      data: request.toApiJson(),
    );
  }

  Future<void> reportUser(
    String targetUserId, {
    required String category,
    String? reason,
  }) async {
    final request = ReportRequest.fromSubmission(
      category: category,
      reason: reason,
    );
    await _dio.post<void>(
      ApiEndpoints.userReport(targetUserId),
      data: request.toApiJson(),
    );
  }

  Future<void> blockUser(String targetUserId) async {
    await _dio.post<void>(ApiEndpoints.userBlock(targetUserId));
  }

  Future<void> unblockUser(String targetUserId) async {
    await _dio.delete<void>(ApiEndpoints.userBlock(targetUserId));
  }
}
