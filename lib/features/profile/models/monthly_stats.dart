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

class MonthlyStats {
  const MonthlyStats({
    required this.yearMonth,
    required this.budgetAmount,
    required this.spentAmount,
    required this.restrainedAmount,
    required this.usageRate,
    required this.boughtCount,
    required this.restrainedCount,
  });

  final String yearMonth;
  final int budgetAmount;
  final int spentAmount;
  final int restrainedAmount;
  final int usageRate;
  final int boughtCount;
  final int restrainedCount;

  String get displayMonth => yearMonthToDisplay(yearMonth);

  bool get isExceeded => budgetAmount > 0 && spentAmount > budgetAmount;

  double get progressFactor {
    if (budgetAmount <= 0) return 0;
    return (spentAmount / budgetAmount).clamp(0.0, 1.0);
  }

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      yearMonth: json['yearMonth'] as String? ?? '',
      budgetAmount: _asInt(json['budgetAmount']),
      spentAmount: _asInt(json['spentAmount']),
      restrainedAmount: _asInt(json['restrainedAmount']),
      usageRate: _asInt(json['usageRate']),
      boughtCount: _asInt(json['boughtCount']),
      restrainedCount: _asInt(json['restrainedCount']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
