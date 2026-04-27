import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsiderState {
  final Map<int, bool?> answers;
  final int totalQuestions;
  final String budgetPercent;
  final String opportunityCost;

  ConsiderState({
    required this.answers,
    this.totalQuestions = 4,
    this.budgetPercent = "23%",
    this.opportunityCost = "라떼 8잔",
  });

  int get yesCount => answers.values.where((v) => v == true).length;
  bool get isAllAnswered => answers.length == totalQuestions && !answers.values.contains(null);
  bool get shouldShowWarning => isAllAnswered && yesCount >= 2;

  ConsiderState copyWith({Map<int, bool?>? answers}) {
    return ConsiderState(answers: answers ?? this.answers);
  }
}

class ConsiderViewModel extends StateNotifier<ConsiderState> {
  ConsiderViewModel() : super(ConsiderState(answers: {}));

  void setAnswer(int index, bool value) {
    final newAnswers = Map<int, bool?>.from(state.answers);
    newAnswers[index] = value;
    state = state.copyWith(answers: newAnswers);
  }
}

final considerViewModelProvider = StateNotifierProvider<ConsiderViewModel, ConsiderState>((ref) => ConsiderViewModel());