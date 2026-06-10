import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/core/network/network_error.dart';
import 'package:fe_app/features/profile/models/consumption_record.dart';
import 'package:fe_app/features/profile/models/wish_history_item.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/features/profile/services/consumption_service.dart';
import 'package:fe_app/features/profile/services/profile_service.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_result_update_request.dart';
import 'package:fe_app/features/wishlist/services/decision_service.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

class MonthlyConsumptionState {
  const MonthlyConsumptionState({
    this.items = const [],
    this.isLoading = false,
    this.updatingItemId,
    this.errorMessage,
    this.budgetBecameExhausted = false,
  });

  final List<WishHistoryItem> items;
  final bool isLoading;
  final String? updatingItemId;
  final String? errorMessage;
  final bool budgetBecameExhausted;

  MonthlyConsumptionState copyWith({
    List<WishHistoryItem>? items,
    bool? isLoading,
    String? updatingItemId,
    String? errorMessage,
    bool? budgetBecameExhausted,
    bool clearUpdating = false,
    bool clearError = false,
    bool clearBudgetFlag = false,
  }) {
    return MonthlyConsumptionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      updatingItemId:
          clearUpdating ? null : (updatingItemId ?? this.updatingItemId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      budgetBecameExhausted: clearBudgetFlag
          ? false
          : (budgetBecameExhausted ?? this.budgetBecameExhausted),
    );
  }
}

class MonthlyConsumptionNotifier extends StateNotifier<MonthlyConsumptionState> {
  MonthlyConsumptionNotifier(
    this._profileService,
    this._consumptionService,
    this._decisionService,
    this._ref,
    this._yearMonth,
  ) : super(const MonthlyConsumptionState());

  final ProfileService _profileService;
  final ConsumptionService _consumptionService;
  final DecisionService _decisionService;
  final Ref _ref;
  final String _yearMonth;

  static const int _pageSize = 100;

  String _errorMessage(Object error, String fallback) {
    if (isNetworkError(error)) {
      return kNetworkErrorMessage;
    }
    final api = apiExceptionFrom(error);
    if (api != null && api.message != '요청을 처리하지 못했습니다.') {
      return api.message;
    }
    if (error is ApiException) return error.message;
    return fallback;
  }

  Future<List<ConsumptionRecord>> _loadConsumptionRecords() async {
    final response = await _consumptionService.getMonthlyConsumption(
      month: _yearMonth,
    );
    return response.items;
  }

  String? _resolveDecisionId(
    WishHistoryItem wish,
    List<ConsumptionRecord> records,
  ) {
    final existing = wish.decisionId;
    if (existing != null && existing.isNotEmpty) return existing;

    final title = wish.title.trim();
    final status = wish.status.toUpperCase();
    if (title.isEmpty || (status != 'GO' && status != 'STOP')) return null;

    final byItemId = records
        .where(
          (record) =>
              record.itemId != null &&
              record.itemId!.isNotEmpty &&
              record.itemId == wish.itemId,
        )
        .toList();
    if (byItemId.length == 1) return byItemId.single.id;

    final exactKey = WishHistoryItem.lookupKey(
      title: wish.title,
      price: wish.price,
      status: wish.status,
    );
    final exactMatches =
        records.where((record) => record.id.isNotEmpty).toList();
    for (final record in exactMatches) {
      if (ConsumptionRecord.lookupKey(
            title: record.itemTitle,
            price: record.price,
            result: record.result,
          ) ==
          exactKey) {
        return record.id;
      }
    }

    final byTitleResult = records
        .where(
          (record) =>
              record.itemTitle.trim() == title &&
              record.result.toUpperCase() == status,
        )
        .toList();
    if (byTitleResult.isEmpty) return null;
    if (byTitleResult.length == 1) return byTitleResult.single.id;

    final wishPrice = wish.price ?? 0;
    final priceMatches = byTitleResult
        .where((record) => (record.price ?? 0) == wishPrice)
        .toList();
    if (priceMatches.length == 1) return priceMatches.single.id;

    if (status == 'STOP') {
      final withoutPrice = byTitleResult
          .where((record) => record.price == null || record.price == 0)
          .toList();
      if (withoutPrice.length == 1) return withoutPrice.single.id;
    }

    byTitleResult.sort((a, b) {
      final aTime = a.decidedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.decidedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return byTitleResult.first.id;
  }

  Future<List<WishHistoryItem>> _fetchWishHistoryForMonth() async {
    final merged = <WishHistoryItem>[];
    var page = 0;
    while (true) {
      final response = await _profileService.getWishHistory(
        yearMonth: _yearMonth,
        page: page,
        size: _pageSize,
      );
      merged.addAll(
        response.wishes.where((item) => item.isDecided),
      );
      if (!response.hasNext) break;
      page++;
    }
    return merged;
  }

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.items.isNotEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true, clearBudgetFlag: true);
    try {
      final results = await Future.wait([
        _fetchWishHistoryForMonth(),
        _loadConsumptionRecords(),
      ]);
      final wishes = results[0] as List<WishHistoryItem>;
      final records = results[1] as List<ConsumptionRecord>;

      final items = wishes
          .map(
            (wish) => wish.copyWith(
              decisionId: _resolveDecisionId(wish, records),
            ),
          )
          .toList();

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(e, '소비기록을 불러오지 못했습니다.'),
      );
    }
  }

  Future<bool> updateDecisionResult({
    required WishHistoryItem item,
    required bool toGo,
  }) async {
    final newStatus =
        toGo ? ItemStatus.go.apiValue : ItemStatus.stop.apiValue;
    if (item.status.toUpperCase() == newStatus) return true;

    var decisionId = item.decisionId;
    if (decisionId == null || decisionId.isEmpty) {
      final records = await _loadConsumptionRecords();
      decisionId = _resolveDecisionId(item, records);
    }
    if (decisionId == null || decisionId.isEmpty) {
      state = state.copyWith(
        errorMessage: '결정 정보를 찾을 수 없어 수정할 수 없습니다.',
      );
      return false;
    }
    if (state.updatingItemId != null) return false;

    state = state.copyWith(
      updatingItemId: item.itemId,
      clearError: true,
      clearBudgetFlag: true,
    );
    try {
      final response = await _decisionService.updateDecisionResult(
        decisionId: decisionId,
        request: DecisionResultUpdateRequest(
          result: toGo
              ? PurchaseDecisionResult.go.apiValue
              : PurchaseDecisionResult.stop.apiValue,
          finalPrice: toGo && (item.price ?? 0) > 0 ? item.price : null,
        ),
      );

      final updatedStatus = response.result.toUpperCase();
      final updatedItems = state.items.map((row) {
        if (row.itemId != item.itemId) return row;
        return row.copyWith(
          status: updatedStatus,
          decisionId: decisionId,
        );
      }).toList();

      state = state.copyWith(
        items: updatedItems,
        clearUpdating: true,
        budgetBecameExhausted: response.budgetBecameExhausted,
      );

      await _ref
          .read(consumptionStatsProvider.notifier)
          .refreshMonthStats(_yearMonth);
      return true;
    } catch (e) {
      state = state.copyWith(
        clearUpdating: true,
        errorMessage: _errorMessage(e, '결정을 변경하지 못했습니다.'),
      );
      return false;
    }
  }
}

final monthlyConsumptionProvider = StateNotifierProvider.autoDispose
    .family<MonthlyConsumptionNotifier, MonthlyConsumptionState, String>(
  (ref, yearMonth) => MonthlyConsumptionNotifier(
    ref.watch(profileServiceProvider),
    ref.watch(consumptionServiceProvider),
    ref.watch(decisionServiceProvider),
    ref,
    yearMonth,
  ),
);
