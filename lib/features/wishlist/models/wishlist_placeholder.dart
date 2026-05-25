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
  final String? imageUrl;

  WishlistPlaceholder copyWith({
    String? id,
    String? title,
    int? price,
    String? category,
    String? link,
    String? imageUrl,
    bool clearImageUrl = false,
  }) {
    return WishlistPlaceholder(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      link: link ?? this.link,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
    );
  }
}
