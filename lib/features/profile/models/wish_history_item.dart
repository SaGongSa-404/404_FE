class WishHistoryResponse {
  const WishHistoryResponse({
    required this.wishes,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<WishHistoryItem> wishes;
  final int total;
  final int page;
  final int size;

  bool get hasNext => (page + 1) * size < total;

  factory WishHistoryResponse.fromJson(Map<String, dynamic> json) {
    final wishesRaw = json['wishes'];
    return WishHistoryResponse(
      wishes: wishesRaw is List
          ? wishesRaw
              .whereType<Map<String, dynamic>>()
              .map(WishHistoryItem.fromJson)
              .toList()
          : const [],
      total: _asInt(json['total']),
      page: _asInt(json['page']),
      size: _asInt(json['size']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WishHistoryItem {
  const WishHistoryItem({
    required this.itemId,
    required this.title,
    this.price,
    this.imageUrl,
    required this.category,
    required this.status,
    this.decisionId,
  });

  final String itemId;
  final String title;
  final int? price;
  final String? imageUrl;
  final String category;
  final String status;
  final String? decisionId;

  bool get isGo => status.toUpperCase() == 'GO';

  bool get isDecided {
    final normalized = status.toUpperCase();
    return normalized == 'GO' || normalized == 'STOP';
  }

  bool get canEditDecision => decisionId != null && isDecided;

  factory WishHistoryItem.fromJson(Map<String, dynamic> json) {
    return WishHistoryItem(
      itemId: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: _asIntOrNull(json['price']),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  WishHistoryItem copyWith({
    String? status,
    String? decisionId,
  }) {
    return WishHistoryItem(
      itemId: itemId,
      title: title,
      price: price,
      imageUrl: imageUrl,
      category: category,
      status: status ?? this.status,
      decisionId: decisionId ?? this.decisionId,
    );
  }

  static String lookupKey({
    required String title,
    required int? price,
    required String status,
  }) =>
      '$title|${price ?? 0}|${status.toUpperCase()}';

  static int? _asIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
