import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/profile/models/consumption_record.dart';
import 'package:fe_app/features/profile/utils/profile_json.dart';

part 'consumption_service.g.dart';

@Riverpod(keepAlive: true)
ConsumptionService consumptionService(Ref ref) =>
    ConsumptionService(ref.watch(apiClientProvider).dio);

class ConsumptionService {
  const ConsumptionService(this._dio);

  final Dio _dio;

  /// GET /api/v1/my/consumption?month=YYYY-MM — 월별 소비기록 목록.
  Future<ConsumptionListResponse> getMonthlyConsumption({
    required String month,
  }) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.myConsumption,
      queryParameters: {'month': month},
    );
    return ConsumptionListResponse.fromJson(parseProfileJsonMap(res.data));
  }
}
