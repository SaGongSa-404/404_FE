import 'package:dio/dio.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_request.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_response.dart';
import 'package:fe_app/features/wishlist/models/deliberation/deliberation_detail.dart';
import 'package:fe_app/features/wishlist/services/decision_service.dart';
import 'package:fe_app/features/wishlist/services/deliberation_service.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
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
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? submitErrorMessage;
  final DeliberationDetail? detail;
  final DecisionCreateResponse? decisionResponse;
  final Map<int, bool?> answers;
  final PurchaseDecision decision;
  final ConsiderCaseType? caseType;

  const ConsiderState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submitErrorMessage,
    this.detail,
    this.decisionResponse,
    this.answers = const {},
    this.decision = PurchaseDecision.notDecided,
    this.caseType,
  });

  int get totalQuestions => detail?.questions.length ?? 0;

  int get yesCount => answers.values.where((v) => v == true).length;

  bool get isAllAnswered =>
      totalQuestions > 0 &&
      answers.length == totalQuestions &&
      !answers.values.contains(null);

  bool get shouldShowWarning => yesCount >= 2;

  String get budgetPercent {
    final rate = detail?.budget.projectedUsageRate;
    if (rate == null) return '-';
    return '$rate%';
  }

  String get opportunityCost {
    final price = detail?.item.listedPrice;
    if (price == null || price <= 0) return '-';
    return '${formatDeliberationPrice(price)}원';
  }

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
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? submitErrorMessage,
    DeliberationDetail? detail,
    DecisionCreateResponse? decisionResponse,
    Map<int, bool?>? answers,
    PurchaseDecision? decision,
    ConsiderCaseType? caseType,
    bool clearErrorMessage = false,
    bool clearSubmitErrorMessage = false,
    bool clearDetail = false,
    bool clearDecisionResponse = false,
  }) {
    return ConsiderState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      submitErrorMessage: clearSubmitErrorMessage
          ? null
          : (submitErrorMessage ?? this.submitErrorMessage),
      detail: clearDetail ? null : (detail ?? this.detail),
      decisionResponse: clearDecisionResponse
          ? null
          : (decisionResponse ?? this.decisionResponse),
      answers: answers ?? this.answers,
      decision: decision ?? this.decision,
      caseType: caseType ?? this.caseType,
    );
  }
}

class ConsiderViewModel extends StateNotifier<ConsiderState> {
  ConsiderViewModel(this._ref, this._itemId) : super(const ConsiderState(isLoading: true)) {
    load();
  }

  final Ref _ref;
  final String _itemId;

  DeliberationService get _deliberationService =>
      _ref.read(deliberationServiceProvider);

  DecisionService get _decisionService => _ref.read(decisionServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final detail = await _deliberationService.fetchItemDeliberation(_itemId);
      final answers = {
        for (var i = 0; i < detail.questions.length; i++) i: null as bool?,
      };
      state = ConsiderState(
        isLoading: false,
        detail: detail,
        answers: answers,
      );
    } catch (e) {
      final api = apiExceptionFrom(e);
      state = ConsiderState(
        isLoading: false,
        errorMessage: _resolveLoadErrorMessage(api),
      );
    }
  }

  String _resolveLoadErrorMessage(ApiException? api) {
    if (api == null) {
      return '구매 숙려 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
    }
    return switch (api.statusCode) {
      403 => '온보딩을 먼저 완료해 주세요.',
      404 => '위시 상품을 찾을 수 없어요.',
      409 => '이 상품은 이미 결정되어 숙려 화면을 열 수 없어요.',
      _ => api.message,
    };
  }

  String _resolveSubmitErrorMessage(ApiException? api) {
    if (api == null) {
      return '결정을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.';
    }
    return switch (api.statusCode) {
      403 => '온보딩을 먼저 완료해 주세요.',
      404 => '위시 상품을 찾을 수 없어요.',
      409 => '결정을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.',
      _ => api.message,
    };
  }

  DecisionCreateResponse? _parseDecisionFromConflict(Object error) {
    if (error is! DioException) return null;
    if (error.response?.statusCode != 409) return null;

    final data = error.response?.data;
    if (data is! Map<String, dynamic>) return null;
    if (data['decisionId'] == null) return null;

    try {
      return DecisionCreateResponse.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  void setAnswer(int index, bool value) {
    final newAnswers = Map<int, bool?>.from(state.answers);
    newAnswers[index] = value;
    state = state.copyWith(answers: newAnswers, clearSubmitErrorMessage: true);
  }

  Future<DecisionCreateResponse?> submitDecision(PurchaseDecision decision) async {
    if (state.isSubmitting || !state.isAllAnswered) return null;

    final detail = state.detail;
    if (detail == null) return null;

    state = state.copyWith(isSubmitting: true, clearSubmitErrorMessage: true);

    try {
      final request = _buildDecisionRequest(decision, detail);
      final response = await _decisionService.createDecision(request);
      final caseType = resolveConsiderCaseType(
        result: decision == PurchaseDecision.purchase
            ? PurchaseDecisionResult.go.apiValue
            : PurchaseDecisionResult.stop.apiValue,
        selfCheckYesCount: state.yesCount,
        mascotState: response.mascot?.state,
      );

      state = state.copyWith(
        decision: decision,
        caseType: caseType,
        decisionResponse: response,
      );

      _ref.read(wishlistViewModelProvider.notifier).refreshItems();
      return response;
    } catch (e) {
      final conflictBody = _parseDecisionFromConflict(e);
      if (conflictBody != null) {
        final caseType = resolveConsiderCaseType(
          result: decision == PurchaseDecision.purchase
              ? PurchaseDecisionResult.go.apiValue
              : PurchaseDecisionResult.stop.apiValue,
          selfCheckYesCount: state.yesCount,
          mascotState: conflictBody.mascot?.state,
        );
        state = state.copyWith(
          decision: decision,
          caseType: caseType,
          decisionResponse: conflictBody,
        );
        _ref.read(wishlistViewModelProvider.notifier).refreshItems();
        return conflictBody;
      }

      final api = apiExceptionFrom(e);
      state = state.copyWith(
        isSubmitting: false,
        submitErrorMessage: _resolveSubmitErrorMessage(api),
      );
      return null;
    }
  }

  DecisionCreateRequest _buildDecisionRequest(
    PurchaseDecision decision,
    DeliberationDetail detail,
  ) {
    final isGo = decision == PurchaseDecision.purchase;
    final listedPrice = detail.item.listedPrice;

    return DecisionCreateRequest(
      itemId: _itemId,
      result: isGo
          ? PurchaseDecisionResult.go.apiValue
          : PurchaseDecisionResult.stop.apiValue,
      finalPrice: isGo && listedPrice > 0 ? listedPrice : null,
      selfCheckAnswers: [
        for (var i = 0; i < detail.questions.length; i++)
          DecisionSelfCheckAnswer(
            questionCode: detail.questions[i].code,
            answerBoolean: state.answers[i] ?? false,
          ),
      ],
    );
  }

  void clearSubmitError() {
    state = state.copyWith(clearSubmitErrorMessage: true);
  }
}

class ConsiderResultRouteArgs {
  const ConsiderResultRouteArgs({
    required this.response,
    required this.caseType,
  });

  final DecisionCreateResponse response;
  final ConsiderCaseType caseType;
}

ConsiderCaseType? caseTypeFromMascotState(String? state) {
  if (state == null || state.isEmpty) return null;

  final normalized = state.trim().toUpperCase().replaceAll('-', '_');
  return switch (normalized) {
    'RESULT_01_S' => ConsiderCaseType.caseA,
    'RESULT_02_S' => ConsiderCaseType.caseB,
    'RESULT_03_S' => ConsiderCaseType.caseC,
    'RESULT_04_S' => ConsiderCaseType.caseD,
    _ => null,
  };
}

ConsiderCaseType resolveConsiderCaseType({
  required String result,
  required int selfCheckYesCount,
  String? mascotState,
}) {
  final fromMascot = caseTypeFromMascotState(mascotState);
  if (fromMascot != null) return fromMascot;

  final isGo = result.trim().toUpperCase() == PurchaseDecisionResult.go.apiValue;
  final isRational = selfCheckYesCount < 2;

  if (isGo) {
    return isRational ? ConsiderCaseType.caseA : ConsiderCaseType.caseB;
  }
  return isRational ? ConsiderCaseType.caseC : ConsiderCaseType.caseD;
}

ConsiderCaseType considerCaseTypeFromDecision(DecisionCreateResponse response) {
  return resolveConsiderCaseType(
    result: response.result,
    selfCheckYesCount: response.selfCheckYesCount,
    mascotState: response.mascot?.state,
  );
}

final considerViewModelProvider = StateNotifierProvider.autoDispose
    .family<ConsiderViewModel, ConsiderState, String>(
  (ref, itemId) => ConsiderViewModel(ref, itemId),
);
