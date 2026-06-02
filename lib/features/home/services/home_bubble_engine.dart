import 'package:fe_app/features/home/domain/home_bubble_selector.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/bubble_home_status.dart';
import 'package:fe_app/features/home/services/home_bubble_local_store.dart';
import 'package:fe_app/features/home/services/home_bubble_session_manager.dart';

/// 말풍선 노출 후 저장·세션 처리 지침.
class HomeBubbleDisplayCommit {
  const HomeBubbleDisplayCommit({
    this.markSessionShown = false,
    this.markOnboardingShown = false,
    this.markFirstWishShown = false,
    this.clearPendingResult = false,
  });

  final bool markSessionShown;
  final bool markOnboardingShown;
  final bool markFirstWishShown;
  final bool clearPendingResult;

  static const empty = HomeBubbleDisplayCommit();
}

/// 홈 진입 시 말풍선 평가 결과.
class HomeBubbleEvaluation {
  const HomeBubbleEvaluation({
    required this.selection,
    required this.commit,
  });

  final HomeBubbleSelection selection;
  final HomeBubbleDisplayCommit commit;
}

/// §14 홈 진입 처리 흐름 orchestrator.
class HomeBubbleEngine {
  HomeBubbleEngine({
    required HomeBubbleSelector selector,
    required HomeBubbleSessionManager sessionManager,
    required HomeBubbleLocalStore localStore,
  })  : _selector = selector,
        _sessionManager = sessionManager,
        _localStore = localStore;

  final HomeBubbleSelector _selector;
  final HomeBubbleSessionManager _sessionManager;
  final HomeBubbleLocalStore _localStore;

  /// 홈 데이터 로딩 완료 후 호출. pending/세션/우선순위를 반영해 말풍선을 결정한다.
  Future<HomeBubbleEvaluation?> evaluateForHomeEntry({
    required BubbleHomeStatus status,
  }) async {
    final pendingResult = await _localStore.peekPendingResultBubble();
    if (pendingResult != null) {
      final selection = _selector.selectForResultBubble(pendingResult);
      if (selection == null) return null;
      return HomeBubbleEvaluation(
        selection: selection,
        commit: const HomeBubbleDisplayCommit(clearPendingResult: true),
      );
    }

    final localFlags = await _localStore.readFlags();

    final type = _selector.selectTypeForHomeEntry(
      status: status,
      localFlags: localFlags,
    );

    if (type.isSessionGated &&
        _sessionManager.hasShownHomeBubbleInCurrentSession) {
      return null;
    }

    final selection = _selector.selectForHomeEntry(
      status: status,
      localFlags: localFlags,
    );
    if (selection == null) return null;

    return HomeBubbleEvaluation(
      selection: selection,
      commit: HomeBubbleDisplayCommit(
        markSessionShown: selection.type.isSessionGated,
        markOnboardingShown: selection.type == HomeBubbleType.onboarding,
        markFirstWishShown: selection.type == HomeBubbleType.firstWish,
      ),
    );
  }

  /// 말풍선 노출 직후 side effect 적용.
  Future<void> commitAfterDisplayed(HomeBubbleDisplayCommit commit) async {
    if (commit.clearPendingResult) {
      await _localStore.consumePendingResultBubble();
    }
    if (commit.markSessionShown) {
      _sessionManager.markHomeBubbleShownInCurrentSession();
    }
    if (commit.markOnboardingShown) {
      await _localStore.markOnboardingBubbleShown();
    }
    if (commit.markFirstWishShown) {
      await _localStore.markFirstWishBubbleShown();
    }
  }
}
