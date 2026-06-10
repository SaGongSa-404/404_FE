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

  Future<void> load({bool silent = false, bool showLoading = false}) async {
    _cancelToken?.cancel('reload');
    final token = CancelToken();
    _cancelToken = token;

    final hasCachedData = state.valueOrNull != null;
    if (showLoading || (!silent && !hasCachedData)) {
      state = const AsyncLoading();
    }

    try {
      final summary = await _service.fetchSummary(cancelToken: token);
      if (token.isCancelled) return;
      state = AsyncData(summary);
    } catch (error, stackTrace) {
      if (token.isCancelled) return;
      if (hasCachedData && !showLoading) {
        debugPrint('home summary refresh failed: $error\n$stackTrace');
        return;
      }
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() => load(silent: true);

  /// 캐시가 있어도 카드 영역에 로딩 UI를 보여주며 다시 불러온다.
  Future<void> refreshWithLoading() => load(showLoading: true);

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

  /// summary.bubble 표시 후 seen 처리. seenEndpoint 우선, 없으면 type 경로 사용.
  Future<void> acknowledgeHomeBubbleSeen() async {
    final current = state.valueOrNull;
    final bubble = current?.bubble;
    if (current == null || bubble == null || !bubble.shouldShow) return;

    final endpoint = bubble.seenEndpoint?.trim();
    final shouldCallSeenApi = endpoint != null && endpoint.isNotEmpty
        ? true
        : switch (bubble.type) {
            'WELCOME' ||
            'BUDGET_NEGATIVE' ||
            'BUDGET_ZERO' ||
            'DECISION_REACTION' =>
              true,
            _ => false,
          };

    if (shouldCallSeenApi) {
      try {
        if (endpoint != null && endpoint.isNotEmpty) {
          await _service.markBubbleSeenByEndpoint(
            seenEndpoint: endpoint,
            cancelToken: _cancelToken,
          );
        } else {
          await _service.markBubbleSeenByType(
            type: bubble.type,
            cancelToken: _cancelToken,
          );
        }
      } catch (error, stackTrace) {
        debugPrint('home bubble seen api failed: $error\n$stackTrace');
      }
    }

    state = AsyncData(
      current.copyWith(
        bubble: bubble.copyWith(shouldShow: false),
      ),
    );
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


