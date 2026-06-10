enum ItemRetrievalStatus {
  success('SUCCESS'),
  partial('PARTIAL');

  const ItemRetrievalStatus(this.apiValue);
  final String apiValue;

  static ItemRetrievalStatus? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ItemRetrievalStatus.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum ItemInputSource {
  share('SHARE'),
  directInput('DIRECT_INPUT');

  const ItemInputSource(this.apiValue);
  final String apiValue;

  static ItemInputSource? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ItemInputSource.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum ItemCategory {
  fashion('FASHION'),
  beauty('BEAUTY'),
  digital('DIGITAL'),
  living('LIVING'),
  food('FOOD'),
  hobby('HOBBY'),
  subscription('SUBSCRIPTION'),
  etc('ETC');

  const ItemCategory(this.apiValue);
  final String apiValue;

  static ItemCategory? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ItemCategory.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum ItemStatus {
  saved('SAVED'),
  go('GO'),
  stop('STOP'),
  dropped('DROPPED');

  const ItemStatus(this.apiValue);
  final String apiValue;

  static ItemStatus? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ItemStatus.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum PurchaseDecisionResult {
  go('GO'),
  stop('STOP');

  const PurchaseDecisionResult(this.apiValue);
  final String apiValue;

  static PurchaseDecisionResult? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in PurchaseDecisionResult.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum RationalityResult {
  rational('RATIONAL'),
  irrational('IRRATIONAL');

  const RationalityResult(this.apiValue);
  final String apiValue;
}

enum PostVoteType {
  go('GO'),
  stop('STOP');

  const PostVoteType(this.apiValue);
  final String apiValue;

  static PostVoteType? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in PostVoteType.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum PushPlatform {
  ios('IOS'),
  android('ANDROID');

  const PushPlatform(this.apiValue);
  final String apiValue;

  static PushPlatform? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in PushPlatform.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum ReflectionRegretLevel {
  none('NONE'),
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const ReflectionRegretLevel(this.apiValue);
  final String apiValue;

  static ReflectionRegretLevel? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ReflectionRegretLevel.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

/// API_SPEC 2026-06-10 (NF-67) 기준 12종.
enum NotificationType {
  regretCheckReady('REGRET_CHECK_READY'),
  regretCheckFollowUp('REGRET_CHECK_FOLLOW_UP'),
  wishlistReminder('WISHLIST_REMINDER'),
  budgetWarning('BUDGET_WARNING'),
  budgetReset('BUDGET_RESET'),
  socialVote('SOCIAL_VOTE'),
  socialFirstVote('SOCIAL_FIRST_VOTE'),
  socialVoteSummary('SOCIAL_VOTE_SUMMARY'),
  socialDecisionNudge('SOCIAL_DECISION_NUDGE'),
  socialComment('SOCIAL_COMMENT'),
  appUpdate('APP_UPDATE'),
  maintenanceNotice('MAINTENANCE_NOTICE');

  const NotificationType(this.apiValue);
  final String apiValue;

  static NotificationType? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in NotificationType.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }

  static NotificationType? tryParse(String? value) => fromApiValue(value);

  /// 기획 §2 인앱 알림: 앱 실행 중 실시간 반응(투표/댓글/리마인드)만
  /// 폴링 기반 인앱 배너로 노출합니다.
  bool get isInAppRealtime {
    switch (this) {
      case NotificationType.socialVote:
      case NotificationType.socialFirstVote:
      case NotificationType.socialComment:
      case NotificationType.wishlistReminder:
        return true;
      default:
        return false;
    }
  }

  /// 투표 계열 알림 여부. 동일 게시글 인앱 배너 중복 방지 대상.
  bool get isSocialVoteBannerType =>
      this == NotificationType.socialVote ||
      this == NotificationType.socialFirstVote ||
      this == NotificationType.socialVoteSummary;
}

enum HomeBubbleApiType {
  budgetNegative('BUDGET_NEGATIVE'),
  budgetZero('BUDGET_ZERO'),
  decisionReaction('DECISION_REACTION'),
  welcome('WELCOME'),
  pendingWishlist('PENDING_WISHLIST'),
  voteWaiting('VOTE_WAITING'),
  defaultType('DEFAULT');

  const HomeBubbleApiType(this.apiValue);
  final String apiValue;

  static HomeBubbleApiType? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in HomeBubbleApiType.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum TermsType {
  termsOfService('TERMS_OF_SERVICE'),
  privacyPolicy('PRIVACY_POLICY'),
  marketing('MARKETING'),
  ageConfirmation('AGE_CONFIRMATION');

  const TermsType(this.apiValue);
  final String apiValue;

  static TermsType? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in TermsType.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }
}

enum UserStatus {
  active('ACTIVE'),
  suspended('SUSPENDED'),
  banned('BANNED'),
  withdrawn('WITHDRAWN');

  const UserStatus(this.apiValue);
  final String apiValue;

  static UserStatus? fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in UserStatus.values) {
      if (item.apiValue == normalized) return item;
    }
    return null;
  }

  bool get isRestricted =>
      this == UserStatus.suspended ||
      this == UserStatus.banned ||
      this == UserStatus.withdrawn;
}

enum SelfCheckQuestionCode {
  need('NEED'),
  budget('BUDGET'),
  alternative('ALTERNATIVE'),
  delay('DELAY');

  const SelfCheckQuestionCode(this.apiValue);
  final String apiValue;
}

enum RegretFrequencyChoice {
  lessThanOnce('LESS_THAN_ONCE'),
  oneToThree('ONE_TO_THREE'),
  fourOrMore('FOUR_OR_MORE');

  const RegretFrequencyChoice(this.apiValue);
  final String apiValue;
}

enum OnboardingStatus {
  completed('COMPLETED');

  const OnboardingStatus(this.apiValue);
  final String apiValue;
}
