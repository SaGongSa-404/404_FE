import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:flutter/foundation.dart';

@immutable
class MyPostsState {
  const MyPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.nextCursor,
    this.hasMore = true,
    this.activeOptionPostId,
  });

  final List<FeedPost> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? nextCursor;
  final bool hasMore;
  final String? activeOptionPostId;

  MyPostsState copyWith({
    List<FeedPost>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
    Object? nextCursor = _sentinel,
    bool? hasMore,
    Object? activeOptionPostId = _sentinel,
  }) {
    return MyPostsState(
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
    );
  }

  static const Object _sentinel = Object();
}
