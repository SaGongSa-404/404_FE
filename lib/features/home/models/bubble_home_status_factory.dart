import 'package:fe_app/features/feed/models/feed_post.dart';
import 'package:fe_app/features/home/models/bubble_home_status.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

/// API·상태 데이터 → [BubbleHomeStatus] 조립 헬퍼.
abstract final class BubbleHomeStatusFactory {
  static BubbleHomeStatus fromSummaryAndLists({
    required int remainingAmount,
    List<WishlistItem> wishlistItems = const [],
    List<FeedPost> socialPosts = const [],
    required bool wishlistLoaded,
    required bool socialLoaded,
    bool? summaryHasUndecidedWish,
    bool? summaryHasPostWithVotesOrComments,
  }) {
    return BubbleHomeStatus(
      remainingAmount: remainingAmount,
      hasNoWish: wishlistLoaded ? wishlistItems.isEmpty : null,
      hasUndecidedWish:
          wishlistLoaded ? wishlistItems.any(_isUndecidedWish) : null,
      hasSocialReaction:
          socialLoaded ? socialPosts.any(_hasSocialReaction) : null,
      summaryHasUndecidedWish: summaryHasUndecidedWish,
      summaryHasPostWithVotesOrComments: summaryHasPostWithVotesOrComments,
    );
  }

  static bool _isUndecidedWish(WishlistItem item) {
    final status = ItemStatus.fromApiValue(item.status);
    return status == ItemStatus.saved;
  }

  static bool _hasSocialReaction(FeedPost post) {
    if (!post.mine) return false;
    return (post.goCount + post.stopCount) >= 1 || post.commentCount >= 1;
  }
}
