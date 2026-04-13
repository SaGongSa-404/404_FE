import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String nickname;
  final List<String> surveyAnswers;

  OnboardingState({
    this.nickname = '',
    this.surveyAnswers = const [],
  });

  OnboardingState copyWith({
    String? nickname,
    List<String>? surveyAnswers,
  }) {
    return OnboardingState(
      nickname: nickname ?? this.nickname,
      surveyAnswers: surveyAnswers ?? this.surveyAnswers,
    );
  }
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  OnboardingViewModel() : super(OnboardingState());

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void addSurveyAnswer(String answer) {
    final updatedAnswers = List<String>.from(state.surveyAnswers)..add(answer);
    state = state.copyWith(surveyAnswers: updatedAnswers);
  }

  void resetSurvey() {
    state = state.copyWith(surveyAnswers: []);
  }
}

final onboardingProvider =
StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel();
});