import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/core/network/json_response.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_category_update_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_update_request.dart';
import 'package:fe_app/shared/models/pagination.dart';

part 'wishlist_service.g.dart';

@Riverpod(keepAlive: true)
WishlistService wishlistService(Ref ref) =>
    WishlistService(ref.watch(apiClientProvider).dio);

class WishlistService {
  const WishlistService(this._dio);
  final Dio _dio;

  static const int defaultListLimit = 50;

  Future<CursorPage<WishlistItem>> listItems({
    String? category,
    int limit = defaultListLimit,
    String? cursor,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.wishlistItems,
      queryParameters: {
        if (category != null) 'category': category,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
      cancelToken: cancelToken,
    );
    return CursorPage.fromJson(requireJsonMap(res.data), 'items', WishlistItem.fromJson);
  }

  Future<WishlistItem> createItem(WishlistItemSaveRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.wishlistItems,
      data: request.toJson(),
    );
    return WishlistItem.fromJson(requireJsonMap(res.data));
  }

  Future<WishlistItem> updateItem({
    required String itemId,
    required WishlistItemUpdateRequest request,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.wishlistItem(itemId),
      data: request.toJson(),
    );
    return WishlistItem.fromJson(requireJsonMap(res.data));
  }

  Future<void> updateItemCategory({
    required String itemId,
    required WishlistItemCategoryUpdateRequest request,
  }) async {
    await _dio.patch<void>(
      ApiEndpoints.wishlistItemCategory(itemId),
      data: request.toJson(),
    );
  }

  /// 저장 상품을 DROPPED 처리합니다 (204 No Content).
  Future<void> dropItem({required String itemId}) async {
    await _dio.delete<void>(ApiEndpoints.wishlistItem(itemId));
  }

  static WishlistItem? parseDuplicateExistingItem(ApiException error) {
    final data = error.responseData;
    if (data is! Map<String, dynamic>) return null;
    final existing = data['existingItem'];
    if (existing is! Map<String, dynamic>) return null;
    try {
      return WishlistItem.fromJson(existing);
    } catch (_) {
      return null;
    }
  }
}
