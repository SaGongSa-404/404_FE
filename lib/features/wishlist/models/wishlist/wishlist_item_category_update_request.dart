class WishlistItemCategoryUpdateRequest {
  WishlistItemCategoryUpdateRequest({required String category})
      : category = _normalizeCategory(category);

  final String category;

  static String _normalizeCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category must not be empty', 'category');
    }
    return trimmed;
  }

  Map<String, dynamic> toJson() => {'category': category};
}
