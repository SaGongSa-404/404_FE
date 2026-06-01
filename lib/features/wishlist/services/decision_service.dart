import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_request.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_create_response.dart';
import 'package:fe_app/features/wishlist/models/decision/decision_result_update_request.dart';

part 'decision_service.g.dart';

@Riverpod(keepAlive: true)
DecisionService decisionService(Ref ref) =>
    DecisionService(ref.watch(apiClientProvider).dio);

class DecisionService {
  const DecisionService(this._dio);
  final Dio _dio;

  Future<DecisionCreateResponse> createDecision(
    DecisionCreateRequest request,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.decisions,
      data: request.toJson(),
    );
    return DecisionCreateResponse.fromJson(requireJsonMap(res.data));
  }

  /// PATCH /api/v1/decisions/{decisionId}/result — 구매 결정 결과 변경.
  Future<DecisionCreateResponse> updateDecisionResult({
    required String decisionId,
    required DecisionResultUpdateRequest request,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.decisionResult(decisionId),
      data: request.toJson(),
    );
    return DecisionCreateResponse.fromJson(requireJsonMap(res.data));
  }
}
