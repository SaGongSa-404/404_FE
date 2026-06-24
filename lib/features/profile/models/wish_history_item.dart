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

class WishHistoryReflection {
  const WishHistoryReflection({
    this.satisfactionScore,
    required this.regretLevel,
    this.stillUsing,
    this.reflectionNote,
    this.reflectedAt,
  });

  final int? satisfactionScore;
  final String regretLevel;
  final bool? stillUsing;
  final String? reflectionNote;
  final DateTime? reflectedAt;

  factory WishHistoryReflection.fromJson(Map<String, dynamic> json) {
    final reflectedAtRaw = json['reflectedAt'];
    return WishHistoryReflection(
      satisfactionScore: _asIntOrNull(json['satisfactionScore']),
      regretLevel: json['regretLevel'] as String? ?? '',
      stillUsing: json['stillUsing'] as bool?,
      reflectionNote: json['reflectionNote'] as String?,
      reflectedAt:
          reflectedAtRaw is String ? DateTime.tryParse(reflectedAtRaw) : null,
    );
  }

  static int? _asIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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
    this.reflection,
  });

  final String itemId;
  final String title;
  final int? price;
  final String? imageUrl;
  final String category;
  final String status;
  final String? decisionId;
  final WishHistoryReflection? reflection;

  bool get isGo => status.toUpperCase() == 'GO';

  bool get isDecided {
    final normalized = status.toUpperCase();
    return normalized == 'GO' || normalized == 'STOP';
  }

  /// GO/STOP 결정이 완료된 항목은 소비 결정 수정 UI를 노출합니다.
  bool get canEditDecision => isDecided;

  factory WishHistoryItem.fromJson(Map<String, dynamic> json) {
    final decisionIdRaw = json['decisionId'] ?? json['lastDecisionId'];
    final reflectionRaw = json['reflection'];
    return WishHistoryItem(
      itemId: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: _asIntOrNull(json['price']),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
      decisionId: decisionIdRaw is String && decisionIdRaw.isNotEmpty
          ? decisionIdRaw
          : null,
      reflection: reflectionRaw is Map<String, dynamic>
          ? WishHistoryReflection.fromJson(reflectionRaw)
          : null,
    );
  }

  WishHistoryItem copyWith({
    String? status,
    String? decisionId,
    WishHistoryReflection? reflection,
  }) {
    return WishHistoryItem(
      itemId: itemId,
      title: title,
      price: price,
      imageUrl: imageUrl,
      category: category,
      status: status ?? this.status,
      decisionId: decisionId ?? this.decisionId,
      reflection: reflection ?? this.reflection,
    );
  }

  static String lookupKey({
    required String title,
    required int? price,
    required String status,
  }) =>
      '$title|${price ?? 0}|${status.toUpperCase()}';

  static String titleResultKey({
    required String title,
    required String status,
  }) =>
      '${title.trim()}|${status.toUpperCase()}';

  static int? _asIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
