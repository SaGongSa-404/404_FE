import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/feed/models/create_post_request.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/models/update_post_request.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/feed/viewmodels/feed_state.dart';

class FeedViewModel extends StateNotifier<FeedState> {
  FeedViewModel(this._service) : super(const FeedState());

  final FeedService _service;

  String _errorMessage(Object error) =>
      apiExceptionFrom(error)?.message ?? '요청을 처리하지 못했습니다.';

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.posts.isNotEmpty) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    try {
      final page = await _service.listPosts();
      state = state.copyWith(
        posts: _withoutBlocked(page.items),
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
      final page = await _service.listPosts();
      state = state.copyWith(
        posts: _withoutBlocked(page.items),
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
      final page = await _service.listPosts(cursor: state.nextCursor);
      state = state.copyWith(
        posts: [...state.posts, ..._withoutBlocked(page.items)],
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

  /// 같은 표 재탭 시 BE가 취소(`myVote=null`) 처리하므로 클라이언트에서 차단하지 않습니다.
  Future<void> vote(String postId, VoteType voteType) async {
    try {
      final res = await _service.votePost(postId, voteType);
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

  Future<FeedPost?> addPost(CreatePostRequest request) async {
    try {
      final created = await _service.createPost(request);
      state = state.copyWith(posts: [created, ...state.posts]);
      return created;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return null;
    }
  }

  Future<FeedPost?> updatePost(String postId, UpdatePostRequest request) async {
    try {
      final updated = await _service.updatePost(postId, request);
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

  Future<bool> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      final commentsMap = Map<String, CommentsPage>.from(state.commentsMap)
        ..remove(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
        commentsMap: commentsMap,
        activeOptionPostId: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  /// 상세 진입 시 단건 최신화 (실패해도 무시 — 캐시 사용).
  Future<void> refreshPost(String postId) async {
    try {
      final fresh = await _service.getPost(postId);
      final exists = state.posts.any((p) => p.id == postId);
      state = state.copyWith(
        posts: exists
            ? state.posts.map((p) => p.id == postId ? fresh : p).toList()
            : [fresh, ...state.posts],
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> loadComments(String postId, {bool refresh = false}) async {
    final existing = state.commentsMap[postId];
    if (!refresh && existing != null && existing.items.isNotEmpty) return;
    final current = existing ?? const CommentsPage();
    state = state.copyWith(commentsMap: {
      ...state.commentsMap,
      postId: current.copyWith(isLoading: true, errorMessage: null),
    });
    try {
      final page = await _service.listComments(postId, page: 1);
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: CommentsPage(
          items: page.items,
          total: page.total,
          page: page.page,
          size: page.size,
        ),
        // commentCount/preview 동기화
      });
      _syncCommentMetaFromPage(postId);
    } catch (e) {
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: current.copyWith(
          isLoading: false,
          errorMessage: _errorMessage(e),
        ),
      });
    }
  }

  Future<void> loadMoreComments(String postId) async {
    final existing = state.commentsMap[postId];
    if (existing == null || existing.isLoading || !existing.hasMore) return;
    state = state.copyWith(commentsMap: {
      ...state.commentsMap,
      postId: existing.copyWith(isLoading: true),
    });
    try {
      final nextPage = await _service.listComments(
        postId,
        page: existing.page + 1,
      );
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: existing.copyWith(
          items: [...existing.items, ...nextPage.items],
          total: nextPage.total,
          page: nextPage.page,
          size: nextPage.size,
          isLoading: false,
        ),
      });
    } catch (e) {
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: existing.copyWith(
          isLoading: false,
          errorMessage: _errorMessage(e),
        ),
      });
    }
  }

  Future<void> addComment(String postId, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    try {
      final created = await _service.createComment(postId, trimmed);
      final existing = state.commentsMap[postId] ?? const CommentsPage();
      final updated = existing.copyWith(
        items: [...existing.items, created],
        total: existing.total + 1,
      );
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: updated,
      });
      _applyCommentMeta(
        postId,
        commentCount: updated.total,
        latestCommentText: created.body,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _service.deleteComment(postId, commentId);
      final existing = state.commentsMap[postId];
      if (existing == null) return;
      final items = existing.items.where((c) => c.id != commentId).toList();
      final updated = existing.copyWith(
        items: items,
        total: (existing.total - 1).clamp(0, 1 << 31),
      );
      state = state.copyWith(commentsMap: {
        ...state.commentsMap,
        postId: updated,
      });
      _applyCommentMeta(
        postId,
        commentCount: updated.total,
        latestCommentText: items.isEmpty ? null : items.last.body,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
    }
  }

  Future<bool> reportPost(String postId, String reason) async {
    try {
      await _service.reportPost(postId, reason);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  Future<bool> reportComment(
    String postId,
    String commentId,
    String reason,
  ) async {
    try {
      await _service.reportComment(postId, commentId, reason);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  /// 사용자 차단: 서버에 차단 요청 후 로컬 상태에서 해당 작성자의 글/댓글을 즉시 숨깁니다.
  /// 작성자 ID 기준으로 숨기므로 동일 닉네임 사용자가 함께 사라지지 않습니다.
  Future<bool> blockUser({required String authorUserId}) async {
    try {
      await _service.blockUser(authorUserId);
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
    _hideAuthorLocally(authorUserId);
    return true;
  }

  void _hideAuthorLocally(String authorUserId) {
    final removedPostIds = state.posts
        .where((p) => p.authorUserId == authorUserId)
        .map((p) => p.id)
        .toSet();
    // 차단 작성자의 댓글을 로딩된 모든 글에서 제거하고, 그만큼 댓글 수를 보정합니다.
    // 차단 작성자의 글 자체는 사라지므로 해당 댓글 캐시도 함께 폐기합니다.
    final updatedMap = <String, CommentsPage>{};
    state.commentsMap.forEach((postId, page) {
      if (removedPostIds.contains(postId)) return;
      final kept =
          page.items.where((c) => c.authorUserId != authorUserId).toList();
      final removed = page.items.length - kept.length;
      updatedMap[postId] = page.copyWith(
        items: kept,
        total: (page.total - removed).clamp(0, 1 << 31),
      );
    });
    // 차단 작성자의 글 자체를 제거하고, 남은 글은 변경된 댓글 메타만 동기화합니다.
    final filteredPosts = state.posts
        .where((p) => p.authorUserId != authorUserId)
        .map((p) {
      final page = updatedMap[p.id];
      if (page == null) return p;
      return p.copyWith(
        commentCount: page.total,
        latestCommentText: page.items.isEmpty ? null : page.items.last.body,
      );
    }).toList();
    state = state.copyWith(
      posts: filteredPosts,
      commentsMap: updatedMap,
      blockedUserIds: {...state.blockedUserIds, authorUserId},
      activeOptionPostId: null,
    );
  }

  /// 이미 차단한 작성자의 글을 (서버 반영 지연 등에 대비해) 클라이언트에서도 한 번 더 거릅니다.
  List<FeedPost> _withoutBlocked(List<FeedPost> posts) {
    if (state.blockedUserIds.isEmpty) return posts;
    return posts
        .where((p) => !state.blockedUserIds.contains(p.authorUserId))
        .toList();
  }

  Future<String?> uploadImage(File file) async {
    try {
      return await _service.uploadImage(file);
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return null;
    }
  }

  void _syncCommentMetaFromPage(String postId) {
    final page = state.commentsMap[postId];
    if (page == null) return;
    _applyCommentMeta(
      postId,
      commentCount: page.total,
      latestCommentText: page.items.isEmpty ? null : page.items.last.body,
    );
  }

  void _applyCommentMeta(
    String postId, {
    required int commentCount,
    required String? latestCommentText,
  }) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          commentCount: commentCount,
          latestCommentText: latestCommentText,
        );
      }).toList(),
    );
  }
}
