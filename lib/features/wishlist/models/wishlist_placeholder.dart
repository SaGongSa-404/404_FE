class WishlistPlaceholder {
  const WishlistPlaceholder({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.link,
    this.imageUrl,
    this.status = 'SAVED',
  });

  final String id;
  final String title;
  final int price;
  final String category;
  final String link;
  final String? imageUrl;

  /// 서버 item status (예: SAVED, GO, STOP). 숙려 화면은 SAVED만 진입 가능.
  final String status;

  bool get canOpenDeliberation =>
      status.trim().toUpperCase() == 'SAVED' || status.trim().isEmpty;

  WishlistPlaceholder copyWith({
    String? id,
    String? title,
    int? price,
    String? category,
    String? link,
    String? imageUrl,
    String? status,
    bool clearImageUrl = false,
  }) {
    return WishlistPlaceholder(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      link: link ?? this.link,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      status: status ?? this.status,
    );
  }
}
