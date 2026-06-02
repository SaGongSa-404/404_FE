/// 홈 말풍선 판단용 홈 상태 스냅샷.
///
/// [hasNoWish], [hasUndecidedWish], [hasSocialReaction]은 각각 해당 API 로드
/// 성공 시에만 true/false가 설정된다. null이면 해당 조건은 판단에서 제외한다.
///
/// 추후 home summary에 boolean flag가 추가되면 [summaryHasUndecidedWish] 등을
/// 우선 사용할 수 있다.
class BubbleHomeStatus {
  const BubbleHomeStatus({
    required this.remainingAmount,
    this.hasNoWish,
    this.hasUndecidedWish,
    this.hasSocialReaction,
    this.summaryHasUndecidedWish,
    this.summaryHasPostWithVotesOrComments,
  });

  final int remainingAmount;

  /// null: wishlist API 미로드/실패 → empty·undecided 조건 스킵
  final bool? hasNoWish;

  /// null: wishlist API 미로드/실패 → undecided 조건 스킵
  final bool? hasUndecidedWish;

  /// null: social API 미로드/실패 → socialReaction 조건 스킵
  final bool? hasSocialReaction;

  /// 추후 home summary.hasUndecidedWish 대응용.
  final bool? summaryHasUndecidedWish;

  /// 추후 home summary.hasPostWithVotesOrComments 대응용.
  final bool? summaryHasPostWithVotesOrComments;

  bool get effectiveHasNoWish => hasNoWish ?? false;

  bool get effectiveHasUndecidedWish =>
      summaryHasUndecidedWish ?? hasUndecidedWish ?? false;

  bool get effectiveHasSocialReaction =>
      summaryHasPostWithVotesOrComments ?? hasSocialReaction ?? false;
}

/// 로컬 저장소에서 읽은 말풍선 플래그.
class HomeBubbleLocalFlags {
  const HomeBubbleLocalFlags({
    required this.hasShownOnboardingBubble,
    required this.hasShownFirstWishBubble,
    required this.pendingFirstWishBubble,
    required this.pendingOnboardingBubble,
  });

  const HomeBubbleLocalFlags.empty()
      : hasShownOnboardingBubble = false,
        hasShownFirstWishBubble = false,
        pendingFirstWishBubble = false,
        pendingOnboardingBubble = false;

  final bool hasShownOnboardingBubble;
  final bool hasShownFirstWishBubble;
  final bool pendingFirstWishBubble;
  final bool pendingOnboardingBubble;
}
