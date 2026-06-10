import 'package:fe_app/features/home/providers/home_bubble_provider.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면 데이터(말풍선·홈 요약·소비 통계)를 한 번에 새로고침하는 오케스트레이터.
final homeRefreshProvider = Provider<HomeRefreshUseCase>((ref) {
  return HomeRefreshUseCase(ref);
});

class HomeRefreshUseCase {
  HomeRefreshUseCase(this._ref);

  final Ref _ref;

  /// 말풍선 평가를 무효화한 뒤 홈 요약과 소비 통계를 병렬로 새로고침합니다.
  Future<void> refreshAll() async {
    _ref.read(homeBubbleRefreshProvider)();
    await Future.wait([
      _ref.read(homeSummaryProvider.notifier).refresh(),
      _ref.read(consumptionStatsProvider.notifier).load(force: true),
    ]);
  }
}
