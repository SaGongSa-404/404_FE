class WishlistAddFormPrefill {
  const WishlistAddFormPrefill({
    required this.link,
    required this.title,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  final String link;
  final String title;
  final int price;
  final String category;
  final String? imageUrl;
}
