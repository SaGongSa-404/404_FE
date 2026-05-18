// [예시] 위시리스트 도메인 모델 자리. 실제 API 스펙 확정 후 필드를 교체하세요.
class WishlistPlaceholder {
  const WishlistPlaceholder({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.link,
    this.imageUrl,
  });

  final String id;
  final String title;
  final int price;
  final String category;
  final String link;
  /// 비어 있거나 null이면 썸네일 자리에 카메라 placeholder.
  final String? imageUrl;

  WishlistPlaceholder copyWith({
    String? id,
    String? title,
    int? price,
    String? category,
    String? link,
    String? imageUrl,
  }) {
    return WishlistPlaceholder(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
