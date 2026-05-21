import 'package:flutter/foundation.dart';

@immutable
class FeedComment {
  const FeedComment({
    required this.id,
    required this.authorName,
    required this.createdAt,
    required this.content,
    this.isLiked = false,
    this.isMyComment = false,
  });

  final String id;
  final String authorName;
  final String createdAt;
  final String content;
  final bool isLiked;
  final bool isMyComment;

  FeedComment copyWith({bool? isLiked, bool? isMyComment}) => FeedComment(
        id: id,
        authorName: authorName,
        createdAt: createdAt,
        content: content,
        isLiked: isLiked ?? this.isLiked,
        isMyComment: isMyComment ?? this.isMyComment,
      );
}
