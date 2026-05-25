import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/wishlist/models/deliberation/deliberation_response.dart';
import 'package:fe_app/features/wishlist/services/deliberation_service.dart';
import 'package:fe_app/features/wishlist/utils/price_format.dart' show formatKrwAmount;

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

class ConsiderRouteResult {
  const ConsiderRouteResult({
    required this.caseType,
    required this.itemId,
  });

  final ConsiderCaseType caseType;
  final String itemId;
}

class ConsiderState {
  const ConsiderState({
    required this.answers,
    this.deliberation,
    this.isLoading = false,
    this.loadError,
    this.totalQuestions = 4,
    this.budgetPercent = '0%',
    this.opportunityCost = '',
    this.decision = PurchaseDecision.notDecided,
    this.caseType,
  });

  final Map<int, bool?> answers;
  final DeliberationResponse? deliberation;
  final bool isLoading;
  final String? loadError;
  final int totalQuestions;
  final String budgetPercent;
  final String opportunityCost;
  final PurchaseDecision decision;
  final ConsiderCaseType? caseType;

  int get yesCount => answers.values.where((v) => v == true).length;

  bool get isAllAnswered =>
      totalQuestions > 0 &&
      answers.length == totalQuestions &&
      !answers.values.contains(null);

  bool get shouldShowWarning => yesCount >= 2;

  bool get hasData => deliberation != null;

  List<DeliberationQuestion> get questions =>
      deliberation?.questions ?? const [];

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
    DeliberationResponse? deliberation,
    bool? isLoading,
    String? loadError,
    bool clearLoadError = false,
    int? totalQuestions,
    String? budgetPercent,
    String? opportunityCost,
    PurchaseDecision? decision,
    ConsiderCaseType? caseType,
    bool clearDeliberation = false,
  }) {
    return ConsiderState(
      answers: answers ?? this.answers,
      deliberation: clearDeliberation ? null : (deliberation ?? this.deliberation),
      isLoading: isLoading ?? this.isLoading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      totalQuestions: totalQuestions ?? this.totalQuestions,
      budgetPercent: budgetPercent ?? this.budgetPercent,
      opportunityCost: opportunityCost ?? this.opportunityCost,
      decision: decision ?? this.decision,
      caseType: caseType ?? this.caseType,
    );
  }
}

class ConsiderViewModel extends StateNotifier<ConsiderState> {
  ConsiderViewModel(this._ref, this._itemId)
      : super(const ConsiderState(answers: {}, isLoading: true)) {
    load();
  }

  final Ref _ref;
  final String _itemId;

  DeliberationService get _service => _ref.read(deliberationServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearLoadError: true);
    try {
      final data = await _service.getItemDeliberation(itemId: _itemId);
      final questionCount = data.questions.length;
      state = ConsiderState(
        answers: {},
        deliberation: data,
        isLoading: false,
        totalQuestions: questionCount > 0 ? questionCount : 4,
        budgetPercent: '${data.budget.projectedUsageRate.round()}%',
        opportunityCost: data.opportunityCostMessage,
      );
    } catch (e) {
      final api = apiExceptionFrom(e);
      state = state.copyWith(
        isLoading: false,
        loadError: _messageFor(api),
        clearDeliberation: true,
      );
    }
  }

  String _messageFor(ApiException? api) {
    if (api == null) {
      return '구매 숙려 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
    }
    return switch (api.statusCode) {
      403 => '온보딩을 먼저 완료해 주세요.',
      404 => '위시 상품을 찾을 수 없어요.',
      409 => '저장된 상품만 구매 숙려를 할 수 있어요.',
      _ => api.message,
    };
  }

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

  void resetAnswers() {
    state = state.copyWith(answers: {}, decision: PurchaseDecision.notDecided);
  }

  void reset() {
    final data = state.deliberation;
    if (data == null) {
      state = const ConsiderState(answers: {}, isLoading: true);
      load();
      return;
    }
    state = ConsiderState(
      answers: {},
      deliberation: data,
      totalQuestions: state.totalQuestions,
      budgetPercent: state.budgetPercent,
      opportunityCost: state.opportunityCost,
    );
  }
}

final considerViewModelProvider = StateNotifierProvider.autoDispose
    .family<ConsiderViewModel, ConsiderState, String>(
  (ref, itemId) => ConsiderViewModel(ref, itemId),
);

String deliberationBudgetStatusLabel(num projectedUsageRate) {
  final rate = projectedUsageRate.round();
  if (rate >= 80) return '주의 필요';
  if (rate >= 50) return '보통';
  return '여유 있음';
}

String deliberationSimilarSpendSubtitle({
  required String categoryLabel,
  required num amount,
}) {
  if (amount.round() <= 0) {
    return '지난 달 $categoryLabel\n구매 이력이 없어요';
  }
  return '지난 달 $categoryLabel\n${formatKrwAmount(amount)}원 소비했어요';
}
