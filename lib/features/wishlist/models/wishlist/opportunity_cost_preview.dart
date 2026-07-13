class OpportunityCostPreview {
  const OpportunityCostPreview({
    required this.originalPrice,
    required this.sourceCategory,
    required this.result,
  });

  final int originalPrice;
  final String sourceCategory;
  final OpportunityCostResult result;

  factory OpportunityCostPreview.fromJson(Map<String, dynamic> json) {
    return OpportunityCostPreview(
      originalPrice: _readInt(json['originalPrice']),
      sourceCategory: json['sourceCategory'] as String? ?? '',
      result: OpportunityCostResult.fromJson(
        json['result'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class OpportunityCostResult {
  const OpportunityCostResult({
    required this.itemId,
    required this.targetCategory,
    required this.calculatedCount,
    required this.displayTitle,
    required this.displayMessage,
  });

  final String itemId;
  final String targetCategory;
  final int calculatedCount;
  final String displayTitle;
  final String displayMessage;

  factory OpportunityCostResult.fromJson(Map<String, dynamic> json) {
    return OpportunityCostResult(
      itemId: json['itemId'] as String? ?? '',
      targetCategory: json['targetCategory'] as String? ?? '',
      calculatedCount: _readInt(json['calculatedCount']),
      displayTitle: json['displayTitle'] as String? ?? '',
      displayMessage: json['displayMessage'] as String? ?? '',
    );
  }
}

int _readInt(Object? value) {
  if (value is num) return value.round();
  return 0;
}
