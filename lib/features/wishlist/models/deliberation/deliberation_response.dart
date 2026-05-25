class DeliberationItem {
  const DeliberationItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.listedPrice,
    this.currencyCode,
    required this.category,
    required this.status,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final num? listedPrice;
  final String? currencyCode;
  final String category;
  final String status;

  factory DeliberationItem.fromJson(Map<String, dynamic> json) {
    return DeliberationItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      listedPrice: json['listedPrice'] as num?,
      currencyCode: json['currencyCode'] as String?,
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class DeliberationBudget {
  const DeliberationBudget({
    required this.yearMonth,
    required this.monthlyBudgetAmount,
    required this.spentAmount,
    required this.projectedSpentAmount,
    required this.projectedUsageRate,
  });

  final String yearMonth;
  final num monthlyBudgetAmount;
  final num spentAmount;
  final num projectedSpentAmount;
  final num projectedUsageRate;

  factory DeliberationBudget.fromJson(Map<String, dynamic> json) {
    return DeliberationBudget(
      yearMonth: json['yearMonth'] as String? ?? '',
      monthlyBudgetAmount: json['monthlyBudgetAmount'] as num? ?? 0,
      spentAmount: json['spentAmount'] as num? ?? 0,
      projectedSpentAmount: json['projectedSpentAmount'] as num? ?? 0,
      projectedUsageRate: json['projectedUsageRate'] as num? ?? 0,
    );
  }
}

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

class DeliberationResponse {
  const DeliberationResponse({
    required this.item,
    required this.budget,
    required this.similarCategorySpendAmount,
    required this.opportunityCostMessage,
    required this.questions,
  });

  final DeliberationItem item;
  final DeliberationBudget budget;
  final num similarCategorySpendAmount;
  final String opportunityCostMessage;
  final List<DeliberationQuestion> questions;

  factory DeliberationResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    return DeliberationResponse(
      item: DeliberationItem.fromJson(
        json['item'] as Map<String, dynamic>,
      ),
      budget: DeliberationBudget.fromJson(
        json['budget'] as Map<String, dynamic>,
      ),
      similarCategorySpendAmount:
          json['similarCategorySpendAmount'] as num? ?? 0,
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
