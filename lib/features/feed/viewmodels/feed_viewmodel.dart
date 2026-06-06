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
      final page = await _service.listPosts();
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
      final page = await _service.listPosts(cursor: state.nextCursor);
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

  /// 상세 진입 시 단건 최신화.
  /// 게시글이 삭제(404)됐으면 `true`를 반환하고, 그 외 오류는 캐시를 유지하며 `false`를 반환합니다.
  Future<bool> refreshPost(String postId) async {
    try {
      final fresh = await _service.getPost(postId);
      final exists = state.posts.any((p) => p.id == postId);
      state = state.copyWith(
        posts: exists
            ? state.posts.map((p) => p.id == postId ? fresh : p).toList()
            : [fresh, ...state.posts],
      );
      return false;
    } catch (e) {
      // 삭제된 게시글이면 호출부에서 안내 모달을 띄울 수 있도록 알립니다.
      if (apiExceptionFrom(e)?.statusCode == 404) return true;
      return false; // 기타 오류는 무시 — 캐시 사용
    }
  }

  /// 로컬 목록에서 게시글을 제거합니다. (삭제된 게시글 진입 처리 등)
  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
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
      _applyCommentMeta(postId, commentCount: updated.total);
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
      _applyCommentMeta(postId, commentCount: updated.total);
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
    }
  }

  Future<bool> reportPost(
    String postId, {
    required String category,
    String? reason,
  }) async {
    try {
      await _service.reportPost(postId, category: category, reason: reason);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  Future<bool> reportComment(
    String postId,
    String commentId, {
    required String category,
    String? reason,
  }) async {
    try {
      await _service.reportComment(postId, commentId,
          category: category, reason: reason);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  Future<bool> blockUser({required String authorUserId}) async {
    try {
      await _service.blockUser(authorUserId);
      // 유저 차단이므로 그 유저가 쓴 댓글을 열려 있는 댓글 목록에서 즉시 제거하고,
      // 게시글 목록은 서버 기준으로 새로고침해 일관성을 맞춥니다.
      _removeCommentsByAuthor(authorUserId);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return false;
    }
  }

  /// 차단된 유저가 작성한 모든 댓글을 로컬 댓글 목록에서 제거합니다.
  void _removeCommentsByAuthor(String authorUserId) {
    final newMap = <String, CommentsPage>{};
    var changed = false;
    state.commentsMap.forEach((postId, page) {
      final removed =
          page.items.where((c) => c.authorUserId == authorUserId).length;
      if (removed == 0) {
        newMap[postId] = page;
        return;
      }
      changed = true;
      newMap[postId] = page.copyWith(
        items:
            page.items.where((c) => c.authorUserId != authorUserId).toList(),
        total: (page.total - removed).clamp(0, 1 << 31),
      );
    });
    if (changed) state = state.copyWith(commentsMap: newMap);
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
    _applyCommentMeta(postId, commentCount: page.total);
  }

  void _applyCommentMeta(String postId, {required int commentCount}) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(commentCount: commentCount);
      }).toList(),
    );
  }
}
