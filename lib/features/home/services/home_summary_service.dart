import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/home/models/home_summary.dart';

final homeSummaryServiceProvider = Provider<HomeSummaryService>((ref) {
  return HomeSummaryService(ref.watch(apiClientProvider).dio);
});

class HomeSummaryService {
  const HomeSummaryService(this._dio);

  final Dio _dio;

  Future<HomeSummaryResponse> fetchSummary({CancelToken? cancelToken}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.homeSummary,
      cancelToken: cancelToken,
    );
    return HomeSummaryResponse.fromJson(requireJsonMap(res.data));
  }

  Future<void> markBudgetExhaustionBubbleSeen({CancelToken? cancelToken}) async {
    await _dio.post<void>(
      ApiEndpoints.homeBudgetExhaustionBubbleSeen,
      cancelToken: cancelToken,
    );
  }
}

