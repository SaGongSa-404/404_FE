import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

extension WishlistItemMapper on WishlistItem {
  WishlistPlaceholder toPlaceholder() {
    final displayLink = (normalizedUrl ?? originalUrl ?? '').trim();
    return WishlistPlaceholder(
      id: id,
      title: title,
      price: listedPrice?.round() ?? 0,
      category: WishlistCategoryUi.toUiLabel(category),
      link: displayLink,
      imageUrl: imageUrl,
      status: status,
    );
  }
}

extension WishlistPlaceholderMapper on WishlistPlaceholder {
  WishlistItemSaveRequest toSaveRequest({
    required ItemInputSource inputSource,
    num? categoryConfidence,
    bool? categoryLockedByUser,
    String? sourceDomain,
    String? rawTitle,
    String? rawDescription,
    String? rawPriceText,
    String? rawPayloadJson,
  }) {
    return WishlistItemSaveRequest.fromForm(
      inputSource: inputSource,
      title: title,
      uiCategoryLabel: category,
      link: link,
      listedPrice: price > 0 ? price : null,
      imageUrl: imageUrl,
      categoryConfidence: categoryConfidence,
      categoryLockedByUser: categoryLockedByUser,
      sourceDomain: sourceDomain,
      rawTitle: rawTitle,
      rawDescription: rawDescription,
      rawPriceText: rawPriceText,
      rawPayloadJson: rawPayloadJson,
    );
  }
}
