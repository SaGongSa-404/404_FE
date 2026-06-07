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
}

enum ReflectionRegretLevel {
  none('NONE'),
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const ReflectionRegretLevel(this.apiValue);
  final String apiValue;
}

enum PushPlatform {
  ios('IOS'),
  android('ANDROID');

  const PushPlatform(this.apiValue);
  final String apiValue;
}

enum NotificationType {
  regretCheckReady('REGRET_CHECK_READY'),
  wishlistReminder('WISHLIST_REMINDER'),
  budgetWarning('BUDGET_WARNING'),
  socialVote('SOCIAL_VOTE');

  const NotificationType(this.apiValue);
  final String apiValue;
}

enum TermsType {
  service('SERVICE'),
  privacy('PRIVACY'),
  marketing('MARKETING');

  const TermsType(this.apiValue);
  final String apiValue;
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
