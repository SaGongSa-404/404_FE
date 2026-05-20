import 'package:flutter/foundation.dart';

enum VoteType { none, go, stop }

@immutable
class FeedPost {
  const FeedPost({
    required this.id,
    required this.authorName,
    required this.createdAt,
    required this.content,
    this.productImageUrl,
    this.productName,
    this.productPrice,
    this.productUrl,
    this.goVoteCount = 0,
    this.stopVoteCount = 0,
    this.myVote = VoteType.none,
    this.commentCount = 0,
    this.latestCommentText,
    this.isMyPost = false,
  });

  final String id;
  final String authorName;
  final String createdAt;
  final String content;
  final String? productImageUrl;
  final String? productName;
  final String? productPrice;
  final String? productUrl;
  final int goVoteCount;
  final int stopVoteCount;
  final VoteType myVote;
  final int commentCount;
  final String? latestCommentText;
  final bool isMyPost;

  int get totalVoteCount => goVoteCount + stopVoteCount;

  static const Object _sentinel = Object();

  FeedPost copyWith({
    String? authorName,
    String? createdAt,
    String? content,
    String? productImageUrl,
    String? productName,
    String? productPrice,
    String? productUrl,
    int? goVoteCount,
    int? stopVoteCount,
    VoteType? myVote,
    int? commentCount,
    Object? latestCommentText = _sentinel,
    bool? isMyPost,
  }) {
    return FeedPost(
      id: id,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productUrl: productUrl ?? this.productUrl,
      goVoteCount: goVoteCount ?? this.goVoteCount,
      stopVoteCount: stopVoteCount ?? this.stopVoteCount,
      myVote: myVote ?? this.myVote,
      commentCount: commentCount ?? this.commentCount,
      latestCommentText: latestCommentText == _sentinel
          ? this.latestCommentText
          : latestCommentText as String?,
      isMyPost: isMyPost ?? this.isMyPost,
    );
  }
}
