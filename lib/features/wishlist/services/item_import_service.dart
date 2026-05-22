import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_link_request.dart';
import 'package:fe_app/features/wishlist/models/item_import/item_import_link_response.dart';

part 'item_import_service.g.dart';

@Riverpod(keepAlive: true)
ItemImportService itemImportService(Ref ref) =>
    ItemImportService(ref.watch(apiClientProvider).dio);

class ItemImportService {
  const ItemImportService(this._dio);
  final Dio _dio;

  Future<ItemImportLinkResponse> importLink(ItemImportLinkRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.itemsImportLink,
      data: request.toJson(),
    );
    return ItemImportLinkResponse.fromJson(res.data!);
  }
}
