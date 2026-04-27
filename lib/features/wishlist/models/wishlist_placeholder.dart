// [예시] 위시리스트 도메인 모델 자리. 실제 API 스펙 확정 후 필드를 교체하세요.
class WishlistPlaceholder {
  const WishlistPlaceholder({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.link,
  });

  final String id;
  final String title;
  final int price;
  final String category;
  final String link;

  WishlistPlaceholder copyWith({
    String? id,
    String? title,
    int? price,
    String? category,
    String? link,
  }) {
    return WishlistPlaceholder(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      link: link ?? this.link,
    );
  }
}
