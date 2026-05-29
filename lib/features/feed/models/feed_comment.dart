import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_comment.freezed.dart';
part 'feed_comment.g.dart';

@freezed
class FeedComment with _$FeedComment {
  const factory FeedComment({
    required String id,
    required String body,
    required String authorNickname,
    required DateTime createdAt,
    @Default(false) bool mine,
  }) = _FeedComment;

  factory FeedComment.fromJson(Map<String, dynamic> json) =>
      _$FeedCommentFromJson(json);
}
