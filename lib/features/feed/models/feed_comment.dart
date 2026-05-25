import 'package:flutter/foundation.dart';

@immutable
class FeedComment {
  const FeedComment({
    required this.id,
    required this.authorName,
    required this.createdAt,
    required this.content,
    this.isMyComment = false,
  });

  final String id;
  final String authorName;
  final String createdAt;
  final String content;
  final bool isMyComment;

  FeedComment copyWith({bool? isMyComment}) => FeedComment(
        id: id,
        authorName: authorName,
        createdAt: createdAt,
        content: content,
        isMyComment: isMyComment ?? this.isMyComment,
      );
}
