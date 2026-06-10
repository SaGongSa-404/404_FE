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

  /// GET /api/v1/wishlist/items summary 응답용. metadata·날짜 필드가 없을 수 있습니다.
  factory WishlistItem.fromSummaryJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final now = DateTime.now().toUtc().toIso8601String();
    normalized['createdAt'] ??= now;
    normalized['updatedAt'] ??= normalized['createdAt'] ?? now;
    return WishlistItem.fromJson(normalized);
  }
}
