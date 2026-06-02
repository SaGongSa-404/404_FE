import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/feed/services/feed_service.dart';
import 'package:fe_app/features/home/domain/home_bubble_selector.dart';
import 'package:fe_app/features/home/providers/balloon_message_provider.dart';
import 'package:fe_app/features/home/services/home_summary_service.dart';
import 'package:fe_app/features/home/services/home_bubble_engine.dart';
import 'package:fe_app/features/home/services/home_bubble_local_store.dart';
import 'package:fe_app/features/home/services/home_bubble_session_manager.dart';
import 'package:fe_app/features/home/services/home_bubble_status_service.dart';
import 'package:fe_app/features/wishlist/services/wishlist_service.dart';

final homeBubbleSessionManagerProvider =
    Provider<HomeBubbleSessionManager>((ref) {
  return homeBubbleSessionManager;
});

final homeBubbleSelectorProvider = Provider<HomeBubbleSelector>((ref) {
  return HomeBubbleSelector();
});

final homeBubbleLocalStoreProvider =
    FutureProvider<HomeBubbleLocalStore>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return HomeBubbleLocalStore(prefs);
});

final homeBubbleEngineProvider = FutureProvider<HomeBubbleEngine>((ref) async {
  final localStore = await ref.watch(homeBubbleLocalStoreProvider.future);
  return HomeBubbleEngine(
    selector: ref.watch(homeBubbleSelectorProvider),
    sessionManager: ref.watch(homeBubbleSessionManagerProvider),
    localStore: localStore,
  );
});

final homeBubbleStatusServiceProvider =
    Provider<HomeBubbleStatusService>((ref) {
  return HomeBubbleStatusService(
    homeSummaryService: ref.watch(homeSummaryServiceProvider),
    wishlistService: ref.watch(wishlistServiceProvider),
    feedService: ref.watch(feedServiceProvider),
  );
});

/// 홈 말풍선 판단용 API 로드 (summary 필수 + wishlist/social 보조).
///
/// summary 실패 시 [AsyncError]가 된다. wishlist/social 실패는 결과 내부 flag로 표시된다.
final homeBubbleStatusLoadProvider =
    FutureProvider.autoDispose<HomeBubbleStatusLoadResult>((ref) async {
  final service = ref.watch(homeBubbleStatusServiceProvider);
  return service.load();
});

/// API 상태 + 세션/pending 반영 말풍선 평가.
///
/// [homeBubbleStatusLoadProvider] 완료 후에만 평가한다.
final homeBubbleEvaluationProvider =
    FutureProvider.autoDispose<HomeBubbleEvaluation?>((ref) async {
  final loadResult = await ref.watch(homeBubbleStatusLoadProvider.future);
  final engine = await ref.watch(homeBubbleEngineProvider.future);
  return engine.evaluateForHomeEntry(status: loadResult.bubbleStatus);
});

/// 로드 결과 + 평가 결과를 함께 제공.
class HomeBubbleRuntimeState {
  const HomeBubbleRuntimeState({
    required this.loadResult,
    required this.evaluation,
  });

  final HomeBubbleStatusLoadResult loadResult;
  final HomeBubbleEvaluation? evaluation;
}

final homeBubbleRuntimeProvider =
    FutureProvider.autoDispose<HomeBubbleRuntimeState>((ref) async {
  final loadResult = await ref.watch(homeBubbleStatusLoadProvider.future);
  final evaluation = await ref.watch(homeBubbleEvaluationProvider.future);
  return HomeBubbleRuntimeState(
    loadResult: loadResult,
    evaluation: evaluation,
  );
});

/// 홈 말풍선 API 로드 및 평가를 다시 실행한다.
final homeBubbleRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(homeBubbleStatusLoadProvider);
    ref.invalidate(homeBubbleEvaluationProvider);
    ref.invalidate(homeBubbleRuntimeProvider);
  };
});
