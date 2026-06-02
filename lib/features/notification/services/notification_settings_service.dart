import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';

final notificationSettingsServiceProvider =
    Provider<NotificationSettingsService>((ref) {
  return NotificationSettingsService(ref.watch(apiClientProvider).dio);
});

class NotificationSettingsService {
  const NotificationSettingsService(this._dio);

  final Dio _dio;

  Future<bool> fetchEnabled({CancelToken? cancelToken}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.usersMeNotificationSettings,
      cancelToken: cancelToken,
    );
    return _parseEnabled(res.data);
  }

  Future<bool> updateEnabled(
    bool enabled, {
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.usersMeNotificationSettings,
      data: {'notificationEnabled': enabled},
      cancelToken: cancelToken,
    );
    return _parseEnabled(res.data);
  }

  bool _parseEnabled(Map<String, dynamic>? json) {
    if (json == null) return true;
    final value = json['notificationEnabled'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true';
  }
}
