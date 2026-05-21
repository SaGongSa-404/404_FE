/// 커서 기반 목록 API 공통 필드 (wishlist, social posts 등).
class CursorPage<T> {
  const CursorPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  factory CursorPage.fromJson(
    Map<String, dynamic> json,
    String itemsKey,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final rawItems = json[itemsKey] as List<dynamic>? ?? [];
    return CursorPage(
      items: rawItems
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// page 기반 목록 API 공통 필드 (mypage wishes history, comments 등).
class OffsetPage<T> {
  OffsetPage({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  }) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than 0');
    }
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must be non-negative');
    }
    if (total < 0) {
      throw ArgumentError.value(total, 'total', 'must be non-negative');
    }
  }

  final List<T> items;
  final int total;
  final int page;
  final int size;

  bool get hasNext => (page + 1) * size < total;
}
