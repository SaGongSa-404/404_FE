import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/onboarding/models/onboarding_complete_request.dart';
import 'package:fe_app/features/onboarding/models/onboarding_complete_response.dart';
import 'package:fe_app/features/onboarding/services/onboarding_service.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(onboardingServiceProvider)),
);

class OnboardingRepository {
  const OnboardingRepository(this._service);

  final OnboardingService _service;

  /// [ApiException]을 던집니다. statusCode 409 는 이미 완료 상태이므로 호출부에서 정상 처리합니다.
  Future<OnboardingCompleteResponse> complete(
    OnboardingCompleteRequest request,
  ) async {
    try {
      return await _service.complete(request);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDioException(e);
    }
  }
}
