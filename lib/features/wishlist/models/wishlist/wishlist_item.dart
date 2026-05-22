import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';
part 'wishlist_item.g.dart';

/// POST /api/v1/wishlist/items 응답 및 목록 항목
@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required String id,
    required String userId,
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
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? sourceDomain,
    String? rawTitle,
    String? rawDescription,
    String? rawPriceText,
    String? rawPayloadJson,
    DateTime? extractedAt,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemFromJson(json);
}
