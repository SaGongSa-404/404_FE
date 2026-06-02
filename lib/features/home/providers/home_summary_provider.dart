import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/features/home/services/home_summary_service.dart';

class HomeSummaryNotifier extends StateNotifier<AsyncValue<HomeSummaryResponse?>> {
  HomeSummaryNotifier(this._service) : super(const AsyncLoading()) {
    unawaited(load());
  }

  final HomeSummaryService _service;
  CancelToken? _cancelToken;

  Future<void> load() async {
    _cancelToken?.cancel('reload');
    final token = CancelToken();
    _cancelToken = token;

    state = const AsyncLoading();
    try {
      final summary = await _service.fetchSummary(cancelToken: token);
      if (token.isCancelled) return;
      state = AsyncData(summary);
    } catch (error, stackTrace) {
      if (token.isCancelled) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() => load();

  Future<void> acknowledgeBudgetBubbleSeen() async {
    final current = state.valueOrNull;
    if (current == null || !current.budget.showBudgetExhaustionBubble) return;

    try {
      await _service.markBudgetExhaustionBubbleSeen(cancelToken: _cancelToken);
    } catch (error, stackTrace) {
      debugPrint('budget exhaustion seen api failed: $error\n$stackTrace');
    }

    final updated = current.copyWith(
      budget: current.budget.copyWith(showBudgetExhaustionBubble: false),
    );
    state = AsyncData(updated);
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }
}

final homeSummaryProvider =
    StateNotifierProvider<HomeSummaryNotifier, AsyncValue<HomeSummaryResponse?>>((ref) {
  return HomeSummaryNotifier(ref.watch(homeSummaryServiceProvider));
});


