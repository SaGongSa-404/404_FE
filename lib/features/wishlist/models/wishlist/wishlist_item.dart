import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';
part 'wishlist_item.g.dart';

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

    /// 본인이 이 위시 상품으로 작성한 살아있는 피드 글 존재 여부 (목록 응답 전용).
    @Default(false) bool selected,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemFromJson(json);
}
