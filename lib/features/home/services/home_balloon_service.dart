import 'package:fe_app/features/home/domain/home_bubble_selector.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/balloon_message.dart';
import 'package:fe_app/features/home/services/home_bubble_local_store.dart';
import 'package:fe_app/features/home/services/home_bubble_session_manager.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';

/// 기존 호출부와의 호환을 위한 facade.
///
/// 신규 로직은 [HomeBubbleEngine], [HomeBubbleSelector], [HomeBubbleLocalStore]를 사용한다.
class HomeBalloonService {
  HomeBalloonService._();

  static final HomeBubbleSelector _selector = HomeBubbleSelector();
  static HomeBubbleLocalStore? _cachedLocalStore;

  static Future<HomeBubbleLocalStore> _localStore() async {
    _cachedLocalStore ??= await HomeBubbleLocalStore.create();
    return _cachedLocalStore!;
  }

  static Future<void> markPendingOnboarding() async {
    final store = await _localStore();
    await store.markPendingOnboarding();
  }

  static Future<bool> consumePendingOnboarding() async {
    final store = await _localStore();
    final flags = await store.readFlags();
    if (flags.pendingOnboardingBubble) {
      await store.clearPendingOnboarding();
      return true;
    }
    return false;
  }

  static Future<void> markPendingFirstWish() async {
    final store = await _localStore();
    await store.markPendingFirstWish();
  }

  static Future<bool> consumePendingFirstWish() async {
    final store = await _localStore();
    final flags = await store.readFlags();
    if (flags.pendingFirstWishBubble) {
      await store.clearPendingFirstWish();
      return true;
    }
    return false;
  }

  static Future<void> markPendingDecisionCase(ConsiderCaseType caseType) async {
    final store = await _localStore();
    final bubbleType = _selector.mapConsiderCaseToBubbleType(caseType);
    await store.setPendingResultBubble(bubbleType);
  }

  static Future<ConsiderCaseType?> consumePendingDecisionCase() async {
    final store = await _localStore();
    final bubbleType = await store.consumePendingResultBubble();
    if (bubbleType == null) return null;
    return _considerCaseForBubbleType(bubbleType);
  }

  static BalloonMessageType? balloonTypeForDecisionCase(
    ConsiderCaseType caseType,
  ) {
    return _legacyBalloonType(
      _selector.mapConsiderCaseToBubbleType(caseType),
    );
  }

  static String? pickRandomText(BalloonMessageType type) {
    final homeType = _homeBubbleTypeForLegacy(type);
    if (homeType == null) return null;
    return _selector.pickMessage(homeType);
  }

  static String? pickRandomTextForHomeBubble(HomeBubbleType type) {
    return _selector.pickMessage(type);
  }

  static bool get launchEvaluatedThisSession =>
      homeBubbleSessionManager.hasShownHomeBubbleInCurrentSession;

  static void markLaunchEvaluatedThisSession() {
    homeBubbleSessionManager.markHomeBubbleShownInCurrentSession();
  }

  static void resetLaunchEvaluationForTests() {
    homeBubbleSessionManager.resetForTests();
    _cachedLocalStore = null;
  }

  static ConsiderCaseType? _considerCaseForBubbleType(HomeBubbleType type) {
    switch (type) {
      case HomeBubbleType.rationalGo:
        return ConsiderCaseType.caseA;
      case HomeBubbleType.irrationalGo:
        return ConsiderCaseType.caseB;
      case HomeBubbleType.rationalStop:
        return ConsiderCaseType.caseC;
      case HomeBubbleType.irrationalStop:
        return ConsiderCaseType.caseD;
      default:
        return null;
    }
  }

  static BalloonMessageType? _legacyBalloonType(HomeBubbleType type) {
    switch (type) {
      case HomeBubbleType.onboarding:
        return BalloonMessageType.onboarding;
      case HomeBubbleType.emptyWish:
        return BalloonMessageType.emptyWishlist;
      case HomeBubbleType.firstWish:
        return BalloonMessageType.firstWishAdded;
      case HomeBubbleType.undecidedWish:
        return BalloonMessageType.undecidedWish;
      case HomeBubbleType.socialReaction:
        return BalloonMessageType.awaitingVote;
      case HomeBubbleType.defaultHome:
        return BalloonMessageType.normalHome;
      case HomeBubbleType.budgetZero:
        return BalloonMessageType.budgetExhausted;
      case HomeBubbleType.budgetNegative:
        return BalloonMessageType.budgetNegative;
      case HomeBubbleType.rationalGo:
        return BalloonMessageType.rationalBought;
      case HomeBubbleType.rationalStop:
        return BalloonMessageType.rationalRefrained;
      case HomeBubbleType.irrationalStop:
        return BalloonMessageType.irrationalRefrained;
      case HomeBubbleType.irrationalGo:
        return BalloonMessageType.irrationalBought;
    }
  }

  static HomeBubbleType? _homeBubbleTypeForLegacy(BalloonMessageType type) {
    switch (type) {
      case BalloonMessageType.onboarding:
        return HomeBubbleType.onboarding;
      case BalloonMessageType.emptyWishlist:
        return HomeBubbleType.emptyWish;
      case BalloonMessageType.firstWishAdded:
        return HomeBubbleType.firstWish;
      case BalloonMessageType.undecidedWish:
        return HomeBubbleType.undecidedWish;
      case BalloonMessageType.awaitingVote:
        return HomeBubbleType.socialReaction;
      case BalloonMessageType.normalHome:
        return HomeBubbleType.defaultHome;
      case BalloonMessageType.budgetExhausted:
        return HomeBubbleType.budgetZero;
      case BalloonMessageType.budgetNegative:
        return HomeBubbleType.budgetNegative;
      case BalloonMessageType.rationalBought:
        return HomeBubbleType.rationalGo;
      case BalloonMessageType.rationalRefrained:
        return HomeBubbleType.rationalStop;
      case BalloonMessageType.irrationalRefrained:
        return HomeBubbleType.irrationalStop;
      case BalloonMessageType.irrationalBought:
        return HomeBubbleType.irrationalGo;
    }
  }
}
