import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/home/models/bubble_home_status.dart';
import 'package:fe_app/features/home/models/bubble_home_status_factory.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/features/home/services/home_summary_service.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item.dart';
import 'package:fe_app/features/wishlist/services/wishlist_service.dart';

/// 말풍선 상태 판단용 API 로드 결과.
class HomeBubbleStatusLoadResult {
  const HomeBubbleStatusLoadResult({
    required this.summary,
    required this.bubbleStatus,
    required this.wishlistLoadSucceeded,
    required this.socialLoadSucceeded,
    this.wishlistItems = const [],
    this.socialPosts = const [],
    this.wishlistErrorMessage,
    this.socialErrorMessage,
  });

  final HomeSummaryResponse summary;
  final BubbleHomeStatus bubbleStatus;
  final bool wishlistLoadSucceeded;
  final bool socialLoadSucceeded;
  final List<WishlistItem> wishlistItems;
  final List<FeedPost> socialPosts;
  final String? wishlistErrorMessage;
  final String? socialErrorMessage;

  bool get isReadyForBubbleEvaluation => true;
}

/// 홈 말풍선 판단에 필요한 API를 로드하고 [BubbleHomeStatus]를 조립한다.
///
/// - home summary: 필수. 실패 시 예외를 전파한다.
/// - wishlist / social: 보조. 실패해도 summary 기반 상태로 fallback한다.
class HomeBubbleStatusService {
  HomeBubbleStatusService({
    required HomeSummaryService homeSummaryService,
    required WishlistService wishlistService,
    required FeedService feedService,
  })  : _homeSummaryService = homeSummaryService,
        _wishlistService = wishlistService,
        _feedService = feedService;

  static const int bubbleWishlistLimit = 100;
  static const int bubbleSocialPageSize = 20;

  final HomeSummaryService _homeSummaryService;
  final WishlistService _wishlistService;
  final FeedService _feedService;

  Future<HomeBubbleStatusLoadResult> load({CancelToken? cancelToken}) async {
    final summary = await _homeSummaryService.fetchSummary(
      cancelToken: cancelToken,
    );

    final wishlistResult = await _loadWishlistSafely(cancelToken: cancelToken);
    final socialResult = await _loadSocialPostsSafely(cancelToken: cancelToken);

    final bubbleStatus = BubbleHomeStatusFactory.fromSummaryAndLists(
      remainingAmount: summary.budget.remainingAmount,
      wishlistItems: wishlistResult.items,
      socialPosts: socialResult.posts,
      wishlistLoaded: wishlistResult.succeeded,
      socialLoaded: socialResult.succeeded,
    );

    return HomeBubbleStatusLoadResult(
      summary: summary,
      bubbleStatus: bubbleStatus,
      wishlistLoadSucceeded: wishlistResult.succeeded,
      socialLoadSucceeded: socialResult.succeeded,
      wishlistItems: wishlistResult.items,
      socialPosts: socialResult.posts,
      wishlistErrorMessage: wishlistResult.errorMessage,
      socialErrorMessage: socialResult.errorMessage,
    );
  }

  Future<_WishlistLoadResult> _loadWishlistSafely({
    CancelToken? cancelToken,
  }) async {
    try {
      final page = await _wishlistService.listItems(
        limit: bubbleWishlistLimit,
        cancelToken: cancelToken,
      );
      return _WishlistLoadResult(
        succeeded: true,
        items: page.items,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'home bubble wishlist load failed: $error\n$stackTrace',
      );
      return _WishlistLoadResult(
        succeeded: false,
        errorMessage: _resolveErrorMessage(error),
      );
    }
  }

  Future<_SocialLoadResult> _loadSocialPostsSafely({
    CancelToken? cancelToken,
  }) async {
    try {
      final page = await _feedService.listPosts(
        size: bubbleSocialPageSize,
        cancelToken: cancelToken,
      );
      return _SocialLoadResult(
        succeeded: true,
        posts: page.items,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'home bubble social posts load failed: $error\n$stackTrace',
      );
      return _SocialLoadResult(
        succeeded: false,
        errorMessage: _resolveErrorMessage(error),
      );
    }
  }

  String _resolveErrorMessage(Object error) {
    final api = apiExceptionFrom(error);
    if (api != null) return api.message;
    return '요청을 처리하지 못했습니다.';
  }
}

class _WishlistLoadResult {
  const _WishlistLoadResult({
    required this.succeeded,
    this.items = const [],
    this.errorMessage,
  });

  final bool succeeded;
  final List<WishlistItem> items;
  final String? errorMessage;
}

class _SocialLoadResult {
  const _SocialLoadResult({
    required this.succeeded,
    this.posts = const [],
    this.errorMessage,
  });

  final bool succeeded;
  final List<FeedPost> posts;
  final String? errorMessage;
}
