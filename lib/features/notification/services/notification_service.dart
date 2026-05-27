import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(apiClientProvider).dio);
});

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
        .map((item) => _notificationFromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ))
        .toList(growable: false);
  }

  Future<void> markAsRead(String notificationId, {CancelToken? cancelToken}) async {
    await _dio.patch<void>(
      ApiEndpoints.notificationRead(notificationId),
      cancelToken: cancelToken,
    );
  }

  NotificationModel _notificationFromJson(Map<String, dynamic> json) {
    final createdAt = _tryParseDateTime(json['createdAt']);
    final readAt = _tryParseDateTime(json['readAt']);

    return NotificationModel(
      id: _asString(json['id']),
      title: _asString(json['title']),
      time: _formatRelativeTime(createdAt),
      isRead: _asBool(json['read']),
      targetPath: _asString(json['targetPath'], fallback: '/home'),
      body: _asNullableString(json['body']),
      type: _asNullableString(json['type']),
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _asNullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

DateTime? _tryParseDateTime(Object? value) {
  if (value is DateTime) return value;
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${dateTime.month}/${dateTime.day}';
}


