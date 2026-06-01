import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/wishlist/models/deliberation/deliberation_detail.dart';

part 'deliberation_service.g.dart';

@Riverpod(keepAlive: true)
DeliberationService deliberationService(Ref ref) =>
    DeliberationService(ref.watch(apiClientProvider).dio);

class DeliberationService {
  const DeliberationService(this._dio);
  final Dio _dio;

  Future<DeliberationDetail> fetchItemDeliberation(String itemId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.deliberationItem(itemId),
    );
    return DeliberationDetail.fromJson(requireJsonMap(res.data));
  }
}
