import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PurchaseDecision {
  notDecided,
  refrain,
  purchase,
}

enum ConsiderCaseType {
  caseA,
  caseB,
  caseC,
  caseD,
}

class ConsiderState {
  final Map<int, bool?> answers;
  final int totalQuestions;
  final String budgetPercent;
  final String opportunityCost;
  final PurchaseDecision decision;
  final ConsiderCaseType? caseType;

  ConsiderState({
    required this.answers,
    this.totalQuestions = 4,
    this.budgetPercent = "23%",
    this.opportunityCost = "라떼 8잔",
    this.decision = PurchaseDecision.notDecided,
    this.caseType,
  });

  int get yesCount => answers.values.where((v) => v == true).length;

  bool get isAllAnswered =>
      answers.length == totalQuestions && !answers.values.contains(null);

  bool get shouldShowWarning => yesCount >= 2;

  ConsiderCaseType get computedCaseType {
    final rational = yesCount < 2;
    final purchased = decision == PurchaseDecision.purchase;

    if (purchased) {
      return rational ? ConsiderCaseType.caseA : ConsiderCaseType.caseB;
    } else {
      return rational ? ConsiderCaseType.caseC : ConsiderCaseType.caseD;
    }
  }

  ConsiderState copyWith({
    Map<int, bool?>? answers,
    PurchaseDecision? decision,
    ConsiderCaseType? caseType,
  }) {
    return ConsiderState(
      answers: answers ?? this.answers,
      totalQuestions: totalQuestions,
      budgetPercent: budgetPercent,
      opportunityCost: opportunityCost,
      decision: decision ?? this.decision,
      caseType: caseType ?? this.caseType,
    );
  }
}

class ConsiderViewModel extends StateNotifier<ConsiderState> {
  ConsiderViewModel() : super(ConsiderState(answers: {}));

  void setAnswer(int index, bool value) {
    final newAnswers = Map<int, bool?>.from(state.answers);
    newAnswers[index] = value;
    state = state.copyWith(answers: newAnswers);
  }

  ConsiderCaseType recordDecision(PurchaseDecision decision) {
    final newStateWithDecision = state.copyWith(decision: decision);
    final resultType = newStateWithDecision.computedCaseType;
    state = newStateWithDecision.copyWith(
      decision: decision,
      caseType: resultType,
    );
    return resultType;
  }

  void reset() {
    state = ConsiderState(answers: {});
  }
}

final considerViewModelProvider =
    StateNotifierProvider<ConsiderViewModel, ConsiderState>(
  (ref) => ConsiderViewModel(),
);
