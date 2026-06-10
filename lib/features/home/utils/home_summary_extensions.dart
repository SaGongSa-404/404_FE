import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/models/home_summary.dart';

extension HomeSummaryResponseX on HomeSummaryResponse {
  String get defaultVideoBaseName {
    if (budget.exhausted || budget.remainingAmount <= 0) {
      return 'nugul_budget_left_0';
    }
    return 'nugul_home';
  }
}

extension HomeBubbleSummaryX on HomeBubbleSummary {
  HomeBubbleType toHomeBubbleType() {
    switch (type) {
      case 'WELCOME':
        return HomeBubbleType.onboarding;
      case 'BUDGET_NEGATIVE':
        return HomeBubbleType.budgetNegative;
      case 'BUDGET_ZERO':
        return HomeBubbleType.budgetZero;
      case 'PENDING_WISHLIST':
        return HomeBubbleType.emptyWish;
      case 'VOTE_WAITING':
        return HomeBubbleType.socialReaction;
      case 'DECISION_REACTION':
        return HomeBubbleType.rationalGo;
      case 'DEFAULT':
      default:
        return HomeBubbleType.defaultHome;
    }
  }
}
