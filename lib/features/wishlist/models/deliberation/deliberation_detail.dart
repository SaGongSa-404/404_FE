class DeliberationQuestion {
  const DeliberationQuestion({
    required this.code,
    required this.text,
  });

  final String code;
  final String text;

  factory DeliberationQuestion.fromJson(Map<String, dynamic> json) {
    return DeliberationQuestion(
      code: json['code'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class DeliberationItemSummary {
  const DeliberationItemSummary({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.listedPrice,
    required this.currencyCode,
    required this.category,
    required this.status,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final int listedPrice;
  final String currencyCode;
  final String category;
  final String status;

  factory DeliberationItemSummary.fromJson(Map<String, dynamic> json) {
    final price = json['listedPrice'];
    return DeliberationItemSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      listedPrice: price is num ? price.round() : 0,
      currencyCode: json['currencyCode'] as String? ?? 'KRW',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class DeliberationBudgetSummary {
  const DeliberationBudgetSummary({
    required this.yearMonth,
    required this.monthlyBudgetAmount,
    required this.spentAmount,
    required this.projectedSpentAmount,
    required this.projectedUsageRate,
  });

  final String yearMonth;
  final int monthlyBudgetAmount;
  final int spentAmount;
  final int projectedSpentAmount;
  final int projectedUsageRate;

  factory DeliberationBudgetSummary.fromJson(Map<String, dynamic> json) {
    int readInt(Object? value) {
      if (value is num) return value.round();
      return 0;
    }

    return DeliberationBudgetSummary(
      yearMonth: json['yearMonth'] as String? ?? '',
      monthlyBudgetAmount: readInt(json['monthlyBudgetAmount']),
      spentAmount: readInt(json['spentAmount']),
      projectedSpentAmount: readInt(json['projectedSpentAmount']),
      projectedUsageRate: readInt(json['projectedUsageRate']),
    );
  }
}

class DeliberationDetail {
  const DeliberationDetail({
    required this.item,
    required this.budget,
    required this.similarCategorySpendAmount,
    required this.opportunityCostMessage,
    required this.questions,
  });

  final DeliberationItemSummary item;
  final DeliberationBudgetSummary budget;
  final int similarCategorySpendAmount;
  final String opportunityCostMessage;
  final List<DeliberationQuestion> questions;

  factory DeliberationDetail.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    return DeliberationDetail(
      item: DeliberationItemSummary.fromJson(
        json['item'] as Map<String, dynamic>? ?? const {},
      ),
      budget: DeliberationBudgetSummary.fromJson(
        json['budget'] as Map<String, dynamic>? ?? const {},
      ),
      similarCategorySpendAmount: (json['similarCategorySpendAmount'] as num?)
              ?.round() ??
          0,
      opportunityCostMessage:
          json['opportunityCostMessage'] as String? ?? '',
      questions: rawQuestions is List
          ? rawQuestions
              .whereType<Map<String, dynamic>>()
              .map(DeliberationQuestion.fromJson)
              .toList()
          : const [],
    );
  }
}

String deliberationBudgetStatusLabel(int projectedUsageRate) {
  if (projectedUsageRate < 50) return '여유 있음';
  if (projectedUsageRate < 80) return '주의 필요';
  return '예산 부족';
}

String formatDeliberationPrice(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
