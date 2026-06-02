import 'dart:math';

import 'package:fe_app/features/home/domain/home_bubble_messages.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/bubble_home_status.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';

/// 말풍선 우선순위·확률 분기·문구 선택 순수 로직.
class HomeBubbleSelector {
  HomeBubbleSelector({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const double situationalBubbleProbability = 0.7;

  /// 결정 API 응답 → 말풍선 타입.
  HomeBubbleType mapDecisionResultToBubbleType({
    required String result,
    required String rationalityResult,
  }) {
    final normalizedResult = result.trim().toUpperCase();
    final normalizedRationality = rationalityResult.trim().toUpperCase();

    if (normalizedResult == 'GO' && normalizedRationality == 'RATIONAL') {
      return HomeBubbleType.rationalGo;
    }
    if (normalizedResult == 'STOP' && normalizedRationality == 'RATIONAL') {
      return HomeBubbleType.rationalStop;
    }
    if (normalizedResult == 'STOP' && normalizedRationality == 'IRRATIONAL') {
      return HomeBubbleType.irrationalStop;
    }
    if (normalizedResult == 'GO' && normalizedRationality == 'IRRATIONAL') {
      return HomeBubbleType.irrationalGo;
    }

    return HomeBubbleType.defaultHome;
  }

  /// 기존 consider flow(로컬 케이스) → 말풍선 타입.
  HomeBubbleType mapConsiderCaseToBubbleType(ConsiderCaseType caseType) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
        return HomeBubbleType.rationalGo;
      case ConsiderCaseType.caseB:
        return HomeBubbleType.irrationalGo;
      case ConsiderCaseType.caseC:
        return HomeBubbleType.rationalStop;
      case ConsiderCaseType.caseD:
        return HomeBubbleType.irrationalStop;
    }
  }

  /// 일반 홈 진입 시 우선순위에 따라 말풍선 타입을 선택한다.
  ///
  /// [localFlags]는 onboarding·firstWish 최초 1회 판단에 사용한다.
  /// 결정 직후 결과 말풍선은 [selectTypeForHomeEntry] 밖에서 별도 처리한다.
  HomeBubbleType selectTypeForHomeEntry({
    required BubbleHomeStatus status,
    required HomeBubbleLocalFlags localFlags,
  }) {
    if (status.remainingAmount < 0) {
      return HomeBubbleType.budgetNegative;
    }

    if (status.remainingAmount == 0) {
      return HomeBubbleType.budgetZero;
    }

    if (localFlags.pendingOnboardingBubble &&
        !localFlags.hasShownOnboardingBubble) {
      return HomeBubbleType.onboarding;
    }

    if (localFlags.pendingFirstWishBubble &&
        !localFlags.hasShownFirstWishBubble) {
      return HomeBubbleType.firstWish;
    }

    if (status.hasNoWish == true) {
      return HomeBubbleType.emptyWish;
    }

    if (status.effectiveHasUndecidedWish) {
      return _resolveProbabilisticType(
        situationalType: HomeBubbleType.undecidedWish,
        fallbackType: HomeBubbleType.defaultHome,
      );
    }

    if (status.effectiveHasSocialReaction) {
      return _resolveProbabilisticType(
        situationalType: HomeBubbleType.socialReaction,
        fallbackType: HomeBubbleType.defaultHome,
      );
    }

    return HomeBubbleType.defaultHome;
  }

  /// 타입별 후보 문구 중 랜덤 1개를 반환한다.
  String? pickMessage(HomeBubbleType type) {
    final candidates = HomeBubbleMessages.messagesFor(type);
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  HomeBubbleType _resolveProbabilisticType({
    required HomeBubbleType situationalType,
    required HomeBubbleType fallbackType,
  }) {
    if (_random.nextDouble() < situationalBubbleProbability) {
      return situationalType;
    }
    return fallbackType;
  }

  /// 테스트용 Random 주입.
  HomeBubbleSelector withRandom(Random random) {
    return HomeBubbleSelector(random: random);
  }
}

/// 선택 결과.
class HomeBubbleSelection {
  const HomeBubbleSelection({
    required this.type,
    required this.message,
  });

  final HomeBubbleType type;
  final String message;
}

extension HomeBubbleSelectorSelection on HomeBubbleSelector {
  HomeBubbleSelection? selectForHomeEntry({
    required BubbleHomeStatus status,
    required HomeBubbleLocalFlags localFlags,
  }) {
    final type = selectTypeForHomeEntry(
      status: status,
      localFlags: localFlags,
    );
    final message = pickMessage(type);
    if (message == null) return null;
    return HomeBubbleSelection(type: type, message: message);
  }

  HomeBubbleSelection? selectForResultBubble(HomeBubbleType type) {
    final message = pickMessage(type);
    if (message == null) return null;
    return HomeBubbleSelection(type: type, message: message);
  }
}
