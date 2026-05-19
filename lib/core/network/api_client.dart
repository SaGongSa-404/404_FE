import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
import 'package:fe_app/core/network/api_exception.dart';
import 'package:fe_app/core/storage/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage: storage);
});

class ApiClient {
  ApiClient({required SecureStorageService storage, Dio? dio})
      : _dio = dio ?? _buildDio(storage);

  final Dio _dio;
  Dio get dio => _dio;

  static Dio _buildDio(SecureStorageService storage) {
    final baseUrl = EnvConfig.apiBaseUrl;
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(ApiErrorInterceptor());
    dio.interceptors.add(AuthInterceptor(storage, baseUrl));
    return dio;
  }
}

/// [DioException]을 [ApiException]으로 변환해 feature에서 일관되게 처리할 수 있게 합니다.
class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      err.copyWith(error: ApiException.fromDioException(err)),
    );
  }
}

/// Bearer 토큰 첨부, 로컬 개발 시 `X-User-Id`, 401 시 refresh 후 재시도.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._baseUrl);

  final SecureStorageService _storage;
  final String _baseUrl;
  bool _isRefreshing = false;

  static bool _usesDevUserIdHeader(String path) {
    return path.startsWith(ApiEndpoints.v1) ||
        path.startsWith(ApiEndpoints.dev);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final useDevUserIdOnly =
        EnvConfig.devAuthMode == DevAuthMode.xUserId &&
        _usesDevUserIdHeader(options.path);

    if (useDevUserIdOnly) {
      final devUserId = EnvConfig.devUserId;
      if (devUserId != null) {
        options.headers['X-User-Id'] = devUserId;
      }
    } else {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        final devUserId = EnvConfig.devUserId;
        if (devUserId != null && _usesDevUserIdHeader(options.path)) {
          options.headers['X-User-Id'] = devUserId;
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final oldRefreshToken = await _storage.getRefreshToken();
      if (oldRefreshToken == null) throw Exception('저장된 refresh token 없음');

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final res = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.tokenRefresh,
        data: {'refreshToken': oldRefreshToken},
      );

      final newAccessToken = res.data!['accessToken'] as String;
      final newRefreshToken = res.data!['refreshToken'] as String;

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await Dio().fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _storage.clearTokens();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
