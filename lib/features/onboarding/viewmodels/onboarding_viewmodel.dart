import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/home/services/home_balloon_service.dart';
import 'package:fe_app/features/onboarding/models/onboarding_complete_request.dart';
import 'package:fe_app/features/onboarding/repositories/onboarding_repository.dart';

class OnboardingState {
  const OnboardingState({
    this.mascotName = '',
    this.monthlyBudgetAmount,
    this.regretFrequencyChoice,
    this.isLoading = false,
    this.errorMessage,
  });

  final String mascotName;
  final int? monthlyBudgetAmount;

  /// LESS_THAN_ONCE | ONE_TO_THREE | FOUR_OR_MORE
  final String? regretFrequencyChoice;

  final bool isLoading;
  final String? errorMessage;

  OnboardingState copyWith({
    String? mascotName,
    int? monthlyBudgetAmount,
    String? regretFrequencyChoice,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      mascotName: mascotName ?? this.mascotName,
      monthlyBudgetAmount: monthlyBudgetAmount ?? this.monthlyBudgetAmount,
      regretFrequencyChoice:
          regretFrequencyChoice ?? this.regretFrequencyChoice,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  OnboardingViewModel(this._repository, this._ref)
      : super(const OnboardingState());

  final OnboardingRepository _repository;
  final Ref _ref;

  void setMascotName(String name) =>
      state = state.copyWith(mascotName: name);

  void setMonthlyBudget(int amount) =>
      state = state.copyWith(monthlyBudgetAmount: amount);

  void setRegretFrequency(String choice) =>
      state = state.copyWith(regretFrequencyChoice: choice);

  Future<void> _markOnboardingFinishedLocally() async {
    _ref.read(authProvider.notifier).markOnboardingCompleted();
    await _ref.read(authProvider.notifier).refreshFromServer();
    try {
      await HomeBalloonService.markPendingOnboarding();
    } catch (_) {
      // 말풍선 pending 표시 실패는 온보딩 성공에 영향을 주지 않음
    }
  }

  Future<String> _resolveTimezone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      return 'Asia/Seoul';
    }
  }

  /// 온보딩 완료 API 호출. true 반환 시 홈으로 이동, false 반환 시 errorMessage 참조.
  Future<bool> completeOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final authState = _ref.read(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;
    final hasDevUser = EnvConfig.devUserId != null;

    // 비로그인·dev user 없음: API 없이 온보딩 UI만 완료 후 홈 진입
    if (!isLoggedIn && !hasDevUser) {
      try {
        await HomeBalloonService.markPendingOnboarding();
      } catch (_) {}
      state = state.copyWith(isLoading: false);
      return true;
    }

    try {
      final request = OnboardingCompleteRequest(
        mascotName: state.mascotName,
        timezone: await _resolveTimezone(),
        monthlyBudgetAmount: state.monthlyBudgetAmount ?? 0,
        regretFrequencyChoice:
            state.regretFrequencyChoice ?? 'LESS_THAN_ONCE',
      );

      await _repository.complete(request);
      await _markOnboardingFinishedLocally();
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // 이미 온보딩 완료 상태 → 홈으로 이동
        await _markOnboardingFinishedLocally();
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel(ref.watch(onboardingRepositoryProvider), ref);
});
