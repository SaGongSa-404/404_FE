class WishlistItemCategoryUpdateRequest {
  const WishlistItemCategoryUpdateRequest({required this.category});

  final String category;

  Map<String, dynamic> toJson() => {'category': category};
}
