class OnboardingCompleteResponse {
  const OnboardingCompleteResponse({
    required this.userId,
    required this.onboardingStatus,
    required this.budgetYearMonth,
    required this.surveyResponseSetId,
  });

  final String userId;
  final String onboardingStatus;
  final String budgetYearMonth;
  final String surveyResponseSetId;

  factory OnboardingCompleteResponse.fromJson(Map<String, dynamic> json) =>
      OnboardingCompleteResponse(
        userId: json['userId'] as String,
        onboardingStatus: json['onboardingStatus'] as String,
        budgetYearMonth: json['budgetYearMonth'] as String,
        surveyResponseSetId: json['surveyResponseSetId'] as String,
      );
}
