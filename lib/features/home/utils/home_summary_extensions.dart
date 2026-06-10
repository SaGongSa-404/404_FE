import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/shared/enums/api_enums.dart';

extension HomeSummaryResponseX on HomeSummaryResponse {
  String get defaultVideoBaseName {
    if (budget.exhausted || budget.remainingAmount <= 0) {
      return 'nugul_budget_left_0';
    }
    return 'nugul_home';
  }
}

extension HomeBubbleSummaryX on HomeBubbleSummary {
  HomeBubbleApiType? get apiBubbleType => HomeBubbleApiType.fromApiValue(type);

  HomeBubbleType toHomeBubbleType() {
    switch (apiBubbleType) {
      case HomeBubbleApiType.welcome:
        return HomeBubbleType.onboarding;
      case HomeBubbleApiType.budgetNegative:
        return HomeBubbleType.budgetNegative;
      case HomeBubbleApiType.budgetZero:
        return HomeBubbleType.budgetZero;
      case HomeBubbleApiType.pendingWishlist:
        return HomeBubbleType.emptyWish;
      case HomeBubbleApiType.voteWaiting:
        return HomeBubbleType.socialReaction;
      case HomeBubbleApiType.decisionReaction:
        return HomeBubbleType.rationalGo;
      case HomeBubbleApiType.defaultType:
      case null:
        return HomeBubbleType.defaultHome;
    }
  }
}
