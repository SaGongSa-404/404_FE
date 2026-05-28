import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/onboarding/models/onboarding_complete_request.dart';
import 'package:fe_app/features/onboarding/models/onboarding_complete_response.dart';

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService(ref.watch(apiClientProvider).dio),
);

class OnboardingService {
  const OnboardingService(this._dio);

  final Dio _dio;

  Future<OnboardingCompleteResponse> complete(
    OnboardingCompleteRequest request,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.onboardingComplete,
      data: request.toJson(),
    );
    return OnboardingCompleteResponse.fromJson(res.data!);
  }
}
