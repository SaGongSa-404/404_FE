import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_item_save_request.dart';

part 'wishlist_service.g.dart';

@Riverpod(keepAlive: true)
WishlistService wishlistService(Ref ref) =>
    WishlistService(ref.watch(apiClientProvider).dio);

class WishlistService {
  const WishlistService(this._dio);
  final Dio _dio;

  Future<WishlistItem> createItem(WishlistItemSaveRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.wishlistItems,
      data: request.toJson(),
    );
    return WishlistItem.fromJson(res.data!);
  }

  static WishlistItem? parseDuplicateExistingItem(ApiException error) {
    final data = error.responseData;
    if (data is! Map<String, dynamic>) return null;
    final existing = data['existingItem'];
    if (existing is! Map<String, dynamic>) return null;
    return WishlistItem.fromJson(existing);
  }
}
