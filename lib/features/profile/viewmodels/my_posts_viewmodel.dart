import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/update_post_request.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';
import 'package:fe_app/features/profile/viewmodels/my_posts_state.dart';

class MyPostsViewModel extends StateNotifier<MyPostsState> {
  MyPostsViewModel(this._profileService, this._feedService)
      : super(const MyPostsState());

  final ProfileService _profileService;
  final FeedService _feedService;

  String _errorMessage(Object error) =>
      apiExceptionFrom(error)?.message ?? '요청을 처리하지 못했습니다.';

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.posts.isNotEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final page = await _profileService.listMyPosts();
      state = state.copyWith(
        posts: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      nextCursor: null,
      hasMore: true,
    );
    try {
      final page = await _profileService.listMyPosts();
      state = state.copyWith(
        posts: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!state.hasMore || state.nextCursor == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page =
          await _profileService.listMyPosts(cursor: state.nextCursor);
      state = state.copyWith(
        posts: [...state.posts, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<void> vote(String postId, VoteType voteType) async {
    try {
      final res = await _feedService.votePost(postId, voteType);
      state = state.copyWith(
        posts: state.posts
            .map((p) => p.id == postId
                ? p.copyWith(
                    myVote: res.myVote,
                    goCount: res.goCount,
                    stopCount: res.stopCount,
                  )
                : p)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
    }
  }

  void setActiveOption(String? postId) {
    state = state.copyWith(activeOptionPostId: postId);
  }

  /// 상세 진입 전 삭제(404) 여부를 확인합니다. 삭제됐으면 목록에서 제거하고 true 반환.
  Future<bool> checkDeletedAndRemove(String postId) async {
    try {
      await _feedService.getPost(postId);
      return false;
    } catch (e) {
      if (apiExceptionFrom(e)?.statusCode == 404) {
        state = state.copyWith(
          posts: state.posts.where((p) => p.id != postId).toList(),
          activeOptionPostId: null,
        );
        return true;
      }
      return false; // 기타 오류는 진입 허용 (캐시 사용)
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _feedService.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
        activeOptionPostId: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  Future<FeedPost?> updatePost(String postId, UpdatePostRequest request) async {
    try {
      final updated = await _feedService.updatePost(postId, request);
      state = state.copyWith(
        posts: state.posts
            .map((p) => p.id == postId ? updated : p)
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return null;
    }
  }
}
