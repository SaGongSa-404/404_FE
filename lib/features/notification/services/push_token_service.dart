import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:fe_app/core/network/api_client.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushTokenServiceProvider = Provider<PushTokenService>((ref) {
  return PushTokenService(ref.watch(apiClientProvider).dio);
});

class PushTokenService {
  const PushTokenService(this._dio);

  final Dio _dio;

  Future<void> registerToken({
    required String token,
    String? deviceId,
    CancelToken? cancelToken,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.pushTokens,
      data: {
        'token': token,
        'platform': _currentPlatform.apiValue,
        if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      },
      cancelToken: cancelToken,
    );
    if (kDebugMode) {
      debugPrint('[push-token] registered (${_currentPlatform.apiValue})');
    }
  }

  Future<void> deactivateToken({
    required String token,
    CancelToken? cancelToken,
  }) async {
    await _dio.delete<void>(
      ApiEndpoints.pushTokens,
      data: {'token': token},
      cancelToken: cancelToken,
    );
    if (kDebugMode) {
      debugPrint('[push-token] deactivated');
    }
  }

  static PushPlatform get _currentPlatform {
    if (!kIsWeb && Platform.isIOS) return PushPlatform.ios;
    return PushPlatform.android;
  }
}
