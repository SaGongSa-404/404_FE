class WishlistItemCategoryUpdateRequest {
  const WishlistItemCategoryUpdateRequest._({required this.category});

  factory WishlistItemCategoryUpdateRequest({required String category}) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category must not be empty', 'category');
    }
    return WishlistItemCategoryUpdateRequest._(category: trimmed);
  }

  final String category;

  Map<String, dynamic> toJson() => {'category': category};
}
