class ConsumptionListResponse {
  const ConsumptionListResponse({
    required this.month,
    required this.items,
  });

  final String month;
  final List<ConsumptionRecord> items;

  factory ConsumptionListResponse.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return ConsumptionListResponse(
      month: json['month'] as String? ?? '',
      items: itemsRaw is List
          ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(ConsumptionRecord.fromJson)
              .toList()
          : const [],
    );
  }
}

class ConsumptionRecord {
  const ConsumptionRecord({
    required this.id,
    required this.itemTitle,
    this.itemId,
    this.price,
    required this.result,
    this.decidedAt,
    this.isChanged = false,
    this.changeCount = 0,
  });

  final String id;
  final String itemTitle;
  final String? itemId;
  final int? price;
  final String result;
  final DateTime? decidedAt;
  final bool isChanged;
  final int changeCount;

  bool get isGo => result.toUpperCase() == 'GO';

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) {
    final decidedAtRaw = json['decidedAt'];
    final itemIdRaw = json['itemId'] ?? json['wishItemId'];
    return ConsumptionRecord(
      id: json['id'] as String? ?? '',
      itemTitle: json['itemTitle'] as String? ?? '',
      itemId: itemIdRaw is String && itemIdRaw.isNotEmpty ? itemIdRaw : null,
      price: _asIntOrNull(json['price']) ?? _asIntOrNull(json['finalPrice']),
      result: json['result'] as String? ?? '',
      decidedAt:
          decidedAtRaw is String ? DateTime.tryParse(decidedAtRaw) : null,
      isChanged: json['isChanged'] as bool? ?? false,
      changeCount: _asInt(json['changeCount']),
    );
  }

  ConsumptionRecord copyWith({String? result}) {
    return ConsumptionRecord(
      id: id,
      itemTitle: itemTitle,
      itemId: itemId,
      price: price,
      result: result ?? this.result,
      decidedAt: decidedAt,
      isChanged: isChanged,
      changeCount: changeCount,
    );
  }

  static String lookupKey({
    required String title,
    required int? price,
    required String result,
  }) =>
      '$title|${price ?? 0}|${result.toUpperCase()}';

  static String titleResultKey({
    required String title,
    required String result,
  }) =>
      '${title.trim()}|${result.toUpperCase()}';

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
