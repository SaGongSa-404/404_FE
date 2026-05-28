class OnboardingCompleteRequest {
  const OnboardingCompleteRequest({
    required this.mascotName,
    required this.timezone,
    required this.monthlyBudgetAmount,
    required this.regretFrequencyChoice,
  });

  final String mascotName;
  final String timezone;
  final int monthlyBudgetAmount;

  /// LESS_THAN_ONCE | ONE_TO_THREE | FOUR_OR_MORE
  final String regretFrequencyChoice;

  Map<String, dynamic> toJson() => {
        'mascotName': mascotName,
        'timezone': timezone,
        'monthlyBudgetAmount': monthlyBudgetAmount,
        'regretFrequencyChoice': regretFrequencyChoice,
      };
}
