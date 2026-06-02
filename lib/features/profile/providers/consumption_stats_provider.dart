import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/profile/models/monthly_stats.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';

class ConsumptionStatsState {
  const ConsumptionStatsState({
    this.currentMonth,
    this.months = const [],
    this.statsByMonth = const {},
    this.isLoading = false,
    this.isUpdatingBudget = false,
    this.errorMessage,
  });

  final String? currentMonth;
  final List<String> months;
  final Map<String, MonthlyStats> statsByMonth;
  final bool isLoading;
  final bool isUpdatingBudget;
  final String? errorMessage;

  MonthlyStats? get currentMonthStats {
    final month = currentMonth;
    if (month == null) return null;
    return statsByMonth[month];
  }

  /// 월별 소비기록 목록 (이번 달 포함, 최신 월 순).
  List<MonthlyStats> get monthlyRecordStats {
    final current = currentMonth;
    final allMonths = <String>{
      ...months,
      if (current != null && current.isNotEmpty) current,
    };
    final sorted = allMonths.toList()..sort((a, b) => b.compareTo(a));
    return sorted
        .map((m) => statsByMonth[m])
        .whereType<MonthlyStats>()
        .toList();
  }

  MonthlyStats? statsFor(String yearMonth) => statsByMonth[yearMonth];

  ConsumptionStatsState copyWith({
    String? currentMonth,
    List<String>? months,
    Map<String, MonthlyStats>? statsByMonth,
    bool? isLoading,
    bool? isUpdatingBudget,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConsumptionStatsState(
      currentMonth: currentMonth ?? this.currentMonth,
      months: months ?? this.months,
      statsByMonth: statsByMonth ?? this.statsByMonth,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingBudget: isUpdatingBudget ?? this.isUpdatingBudget,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConsumptionStatsNotifier extends StateNotifier<ConsumptionStatsState> {
  ConsumptionStatsNotifier(this._profileService)
      : super(const ConsumptionStatsState());

  final ProfileService _profileService;
  bool _hasFetched = false;

  String _errorMessage(Object error) {
    if (error is DioException &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout)) {
      return '서버에 연결할 수 없습니다. API 주소와 백엔드 실행 여부를 확인해 주세요.';
    }
    final api = apiExceptionFrom(error);
    if (api != null && api.message != '요청을 처리하지 못했습니다.') {
      return api.message;
    }
    if (error is ApiException) return error.message;
    return '소비 통계를 불러오지 못했습니다.';
  }

  String _budgetErrorMessage(Object error) {
    if (error is DioException &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout)) {
      return '서버에 연결할 수 없습니다. API 주소와 백엔드 실행 여부를 확인해 주세요.';
    }
    final api = apiExceptionFrom(error);
    if (api != null && api.message != '요청을 처리하지 못했습니다.') {
      return api.message;
    }
    if (error is ApiException) return error.message;
    return '월 예산을 수정하지 못했습니다.';
  }

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && _hasFetched) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final monthsResponse = await _profileService.getStatsMonths();
      final currentMonth = monthsResponse.currentMonth;
      final months = monthsResponse.months;

      final monthsToFetch = <String>{
        ...months,
        if (currentMonth.isNotEmpty) currentMonth,
      };

      final statsResults = await Future.wait(
        monthsToFetch.map(
          (month) => _profileService.getMonthlyStats(yearMonth: month),
        ),
      );

      final statsByMonth = <String, MonthlyStats>{
        for (final stats in statsResults) stats.yearMonth: stats,
      };

      _hasFetched = true;
      state = state.copyWith(
        currentMonth: currentMonth,
        months: months,
        statsByMonth: statsByMonth,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e),
      );
    }
  }

  Future<MonthlyStats?> loadMonth(String yearMonth) async {
    if (state.statsByMonth.containsKey(yearMonth)) {
      return state.statsByMonth[yearMonth];
    }
    return refreshMonthStats(yearMonth);
  }

  Future<MonthlyStats?> refreshMonthStats(String yearMonth) async {
    try {
      final stats = await _profileService.getMonthlyStats(yearMonth: yearMonth);
      state = state.copyWith(
        statsByMonth: {...state.statsByMonth, yearMonth: stats},
        clearError: true,
      );
      return stats;
    } catch (e) {
      state = state.copyWith(errorMessage: _errorMessage(e));
      return null;
    }
  }

  void applyBudgetOverride(int newBudget) {
    final current = state.currentMonth;
    if (current == null) return;
    final existing = state.statsByMonth[current];
    if (existing == null) return;

    final usageRate = newBudget > 0
        ? ((existing.spentAmount / newBudget) * 100).round()
        : 0;

    state = state.copyWith(
      statsByMonth: {
        ...state.statsByMonth,
        current: MonthlyStats(
          yearMonth: existing.yearMonth,
          budgetAmount: newBudget,
          spentAmount: existing.spentAmount,
          restrainedAmount: existing.restrainedAmount,
          usageRate: usageRate,
          boughtCount: existing.boughtCount,
          restrainedCount: existing.restrainedCount,
        ),
      },
    );
  }

  Future<bool> updateBudget(int monthlyBudget) async {
    if (state.isUpdatingBudget) return false;
    if (monthlyBudget < 1) {
      state = state.copyWith(errorMessage: '예산은 1원 이상이어야 합니다.');
      return false;
    }

    state = state.copyWith(isUpdatingBudget: true, clearError: true);
    try {
      final confirmed =
          await _profileService.updateBudget(monthlyBudget: monthlyBudget);
      applyBudgetOverride(confirmed);
      state = state.copyWith(isUpdatingBudget: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingBudget: false,
        errorMessage: _budgetErrorMessage(e),
      );
      return false;
    }
  }

  void reset() {
    _hasFetched = false;
    state = const ConsumptionStatsState();
  }
}

final consumptionStatsProvider =
    StateNotifierProvider<ConsumptionStatsNotifier, ConsumptionStatsState>(
  (ref) => ConsumptionStatsNotifier(ref.watch(profileServiceProvider)),
);
