import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_link_request.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_link_response.dart';
import 'package:fe_app/features/wishlist/models/item_import/shopping_import_job.dart';

part 'item_import_service.g.dart';

@Riverpod(keepAlive: true)
ItemImportService itemImportService(Ref ref) =>
    ItemImportService(ref.watch(apiClientProvider).dio);

class ItemImportService {
  const ItemImportService(this._dio);
  final Dio _dio;

  /// 동기 fallback. 비동기 전환 안정화·긴급 복구용으로 유지한다.
  Future<ItemImportLinkResponse> importLink(ItemImportLinkRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.itemsImportLink,
      data: request.toJson(),
      options: Options(
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    return ItemImportLinkResponse.fromJson(requireJsonMap(res.data));
  }

  Future<ShoppingImportJobAccepted> submitImportJob(
    ItemImportLinkRequest request, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.itemsImportJobs,
      data: request.toJson(),
      cancelToken: cancelToken,
    );

    return ShoppingImportJobAccepted.fromJson(
      requireJsonMap(response.data),
    );
  }

  Future<ShoppingImportJobResult> getImportJob(
    String jobId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.itemImportJob(jobId),
      cancelToken: cancelToken,
    );

    return ShoppingImportJobResult.fromJson(
      requireJsonMap(response.data),
    );
  }
}
