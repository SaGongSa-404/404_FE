import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

part 'wishlist_item_save_request.freezed.dart';
part 'wishlist_item_save_request.g.dart';

@freezed
class WishlistItemSaveRequest with _$WishlistItemSaveRequest {
  const factory WishlistItemSaveRequest({
    required String inputSource,
    String? originalUrl,
    String? normalizedUrl,
    required String title,
    String? imageUrl,
    num? listedPrice,
    String? currencyCode,
    required String category,
    num? categoryConfidence,
    bool? categoryLockedByUser,
    String? sourceDomain,
    String? rawTitle,
    String? rawDescription,
    String? rawPriceText,
    String? rawPayloadJson,
  }) = _WishlistItemSaveRequest;

  factory WishlistItemSaveRequest.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemSaveRequestFromJson(json);

  factory WishlistItemSaveRequest.fromForm({
    required ItemInputSource inputSource,
    required String title,
    required String uiCategoryLabel,
    String? link,
    int? listedPrice,
    String? imageUrl,
    num? categoryConfidence,
    bool? categoryLockedByUser,
    String? sourceDomain,
    String? rawTitle,
    String? rawDescription,
    String? rawPriceText,
    String? rawPayloadJson,
  }) {
    final trimmedLink = link?.trim();
    final hasLink = trimmedLink != null && trimmedLink.isNotEmpty;
    final uri = hasLink ? Uri.tryParse(trimmedLink) : null;

    return WishlistItemSaveRequest(
      inputSource: inputSource.apiValue,
      originalUrl: hasLink ? trimmedLink : null,
      normalizedUrl: hasLink ? trimmedLink : null,
      title: title.trim(),
      imageUrl: imageUrl,
      listedPrice: listedPrice,
      currencyCode: listedPrice != null ? 'KRW' : null,
      category: WishlistCategoryUi.toApiValue(uiCategoryLabel),
      categoryConfidence: categoryConfidence,
      categoryLockedByUser: categoryLockedByUser,
      sourceDomain: sourceDomain ?? uri?.host,
      rawTitle: rawTitle,
      rawDescription: rawDescription,
      rawPriceText: rawPriceText,
      rawPayloadJson: rawPayloadJson,
    );
  }
}
