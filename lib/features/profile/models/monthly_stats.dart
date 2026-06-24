import 'package:fe_app/features/profile/utils/month_display.dart';

class StatsMonthsResponse {
  const StatsMonthsResponse({
    required this.months,
    required this.currentMonth,
  });

  final List<String> months;
  final String currentMonth;

  factory StatsMonthsResponse.fromJson(Map<String, dynamic> json) {
    final monthsRaw = json['months'];
    return StatsMonthsResponse(
      months: monthsRaw is List
          ? monthsRaw.map((e) => e.toString()).toList()
          : const [],
      currentMonth: json['currentMonth'] as String? ?? '',
    );
  }
}

class CategorySpendAmount {
  const CategorySpendAmount({
    required this.category,
    required this.amount,
  });

  final String category;
  final int amount;

  factory CategorySpendAmount.fromJson(Map<String, dynamic> json) {
    return CategorySpendAmount(
      category: json['category'] as String? ?? '',
      amount: MonthlyStats._asInt(json['amount']),
    );
  }
}

class MonthlyStats {
  const MonthlyStats({
    required this.yearMonth,
    required this.budgetAmount,
    required this.spentAmount,
    required this.restrainedAmount,
    required this.usageRate,
    required this.boughtCount,
    required this.restrainedCount,
    this.categorySpendAmounts = const [],
    this.rationalChoiceRate,
    this.irrationalChoiceCount = 0,
  });

  final String yearMonth;
  final int budgetAmount;
  final int spentAmount;
  final int restrainedAmount;
  final int usageRate;
  final int boughtCount;
  final int restrainedCount;
  final List<CategorySpendAmount> categorySpendAmounts;
  final double? rationalChoiceRate;
  final int irrationalChoiceCount;

  String get displayMonth => yearMonthToDisplay(yearMonth);

  bool get isExceeded => budgetAmount > 0 && spentAmount > budgetAmount;

  double get progressFactor {
    if (budgetAmount <= 0) return 0;
    return (spentAmount / budgetAmount).clamp(0.0, 1.0);
  }

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    final categoriesRaw = json['categorySpendAmounts'];
    return MonthlyStats(
      yearMonth: json['yearMonth'] as String? ?? '',
      budgetAmount: _asInt(json['budgetAmount']),
      spentAmount: _asInt(json['spentAmount']),
      restrainedAmount: _asInt(json['restrainedAmount']),
      usageRate: _asDouble(json['usageRate']).round(),
      boughtCount: _asInt(json['boughtCount']),
      restrainedCount: _asInt(json['restrainedCount']),
      categorySpendAmounts: categoriesRaw is List
          ? categoriesRaw
              .whereType<Map<String, dynamic>>()
              .map(CategorySpendAmount.fromJson)
              .toList()
          : const [],
      rationalChoiceRate: _asDoubleOrNull(json['rationalChoiceRate']),
      irrationalChoiceCount: _asInt(json['irrationalChoiceCount']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asDoubleOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed;
  }
}
