/// 홈 말풍선 타입.
enum HomeBubbleType {
  onboarding,
  emptyWish,
  firstWish,
  undecidedWish,
  socialReaction,
  defaultHome,
  budgetZero,
  budgetNegative,
  rationalGo,
  rationalStop,
  irrationalStop,
  irrationalGo,
}

extension HomeBubbleTypeSessionPolicy on HomeBubbleType {
  /// 일반 홈 말풍선 세션 1회 제한 대상 여부.
  ///
  /// 결정 직후 결과·최초 1회(onboarding/firstWish)는 세션 제한을 받지 않는다.
  bool get isSessionGated {
    switch (this) {
      case HomeBubbleType.rationalGo:
      case HomeBubbleType.rationalStop:
      case HomeBubbleType.irrationalStop:
      case HomeBubbleType.irrationalGo:
      case HomeBubbleType.onboarding:
      case HomeBubbleType.firstWish:
        return false;
      case HomeBubbleType.emptyWish:
      case HomeBubbleType.undecidedWish:
      case HomeBubbleType.socialReaction:
      case HomeBubbleType.defaultHome:
      case HomeBubbleType.budgetZero:
      case HomeBubbleType.budgetNegative:
        return true;
    }
  }

  /// 노출 후 영구 저장이 필요한 최초 1회 타입 여부.
  bool get isOneTimePersistent {
    switch (this) {
      case HomeBubbleType.onboarding:
      case HomeBubbleType.firstWish:
        return true;
      default:
        return false;
    }
  }
}
