import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:flutter/foundation.dart';

@immutable
class CommentsPage {
  const CommentsPage({
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.size = 20,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FeedComment> items;
  final int total;
  final int page;
  final int size;
  final bool isLoading;
  final String? errorMessage;

  bool get hasMore => items.length < total;

  CommentsPage copyWith({
    List<FeedComment>? items,
    int? total,
    int? page,
    int? size,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return CommentsPage(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      size: size ?? this.size,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}

@immutable
class FeedState {
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.nextCursor,
    this.hasMore = true,
    this.activeOptionPostId,
    this.commentsMap = const {},
  });

  final List<FeedPost> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? nextCursor;
  final bool hasMore;
  final String? activeOptionPostId;
  final Map<String, CommentsPage> commentsMap;

  FeedState copyWith({
    List<FeedPost>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
    Object? nextCursor = _sentinel,
    bool? hasMore,
    Object? activeOptionPostId = _sentinel,
    Map<String, CommentsPage>? commentsMap,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
      hasMore: hasMore ?? this.hasMore,
      activeOptionPostId: activeOptionPostId == _sentinel
          ? this.activeOptionPostId
          : activeOptionPostId as String?,
      commentsMap: commentsMap ?? this.commentsMap,
    );
  }

  static const Object _sentinel = Object();
}
