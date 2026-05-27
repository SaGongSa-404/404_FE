import 'package:fe_app/features/feed/models/feed_comment.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:flutter/foundation.dart';

@immutable
class FeedState {
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.activeOptionPostId,
    this.commentsMap = const {},
    this.blockedAuthorNames = const {},
  });

  final List<FeedPost> posts;
  final bool isLoading;
  final String? activeOptionPostId;
  final Map<String, List<FeedComment>> commentsMap;
  final Set<String> blockedAuthorNames;

  FeedState copyWith({
    List<FeedPost>? posts,
    bool? isLoading,
    Object? activeOptionPostId = _sentinel,
    Map<String, List<FeedComment>>? commentsMap,
    Set<String>? blockedAuthorNames,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      activeOptionPostId: activeOptionPostId == _sentinel
          ? this.activeOptionPostId
          : activeOptionPostId as String?,
      commentsMap: commentsMap ?? this.commentsMap,
      blockedAuthorNames: blockedAuthorNames ?? this.blockedAuthorNames,
    );
  }

  static const Object _sentinel = Object();
}
