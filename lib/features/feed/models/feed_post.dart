import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fe_app/features/feed/models/product_section.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';

part 'feed_post.freezed.dart';
part 'feed_post.g.dart';

@freezed
class FeedPost with _$FeedPost {
  const factory FeedPost({
    required String id,
    required String authorNickname,
    required String authorUserId,
    String? title,
    String? body,
    String? imageUrl,
    int? price,
    @Default(0) int goCount,
    @Default(0) int stopCount,
    @Default(0) int commentCount,
    VoteType? myVote,
    ProductSection? product,
    @Default(false) bool linkAvailable,
    required DateTime createdAt,
    @Default(false) bool mine,
  }) = _FeedPost;

  factory FeedPost.fromJson(Map<String, dynamic> json) =>
      _$FeedPostFromJson(json);
}
