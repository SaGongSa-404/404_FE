import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(apiClientProvider).dio);
});

enum MarkAsReadResult {
  success,
  notFound,
  failed,
}

class MarkAllAsReadResult {
  const MarkAllAsReadResult({
    required this.updatedCount,
  });

  final int updatedCount;

  factory MarkAllAsReadResult.fromJson(Map<String, dynamic> json) {
    return MarkAllAsReadResult(
      updatedCount: (json['updatedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class NotificationService {
  const NotificationService(this._dio);

  final Dio _dio;

  Future<List<NotificationModel>> fetchNotifications({
    required bool unreadOnly,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'unreadOnly': unreadOnly,
      },
      cancelToken: cancelToken,
    );

    final rawItems = res.data ?? const <dynamic>[];
    return rawItems
        .whereType<Map>()
        .map((item) => NotificationModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ))
        .toList(growable: false);
  }

  Future<MarkAsReadResult> markAsRead(
    String notificationId, {
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.patch<void>(
        ApiEndpoints.notificationRead(notificationId),
        cancelToken: cancelToken,
      );
      return MarkAsReadResult.success;
    } on DioException catch (error) {
      final apiError = apiExceptionFrom(error);
      if (apiError?.statusCode == 404) {
        return MarkAsReadResult.notFound;
      }
      rethrow;
    }
  }

  Future<MarkAllAsReadResult> markAllAsRead({
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.notificationsReadAll,
      cancelToken: cancelToken,
    );
    return MarkAllAsReadResult.fromJson(res.data ?? const <String, dynamic>{});
  }
}
