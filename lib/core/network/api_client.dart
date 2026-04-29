import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/network/api_endpoints.dart';
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
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor(storage, baseUrl));
    return dio;
  }
}

/// 모든 API 요청에 Bearer 토큰을 첨부하고,
/// 401 응답 시 토큰을 갱신한 뒤 원래 요청을 재시도합니다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._baseUrl);

  final SecureStorageService _storage;
  final String _baseUrl;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
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

      // 인터셉터 루프 방지를 위해 별도 Dio 인스턴스로 갱신 호출
      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final res = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.tokenRefresh,
        data: {'refreshToken': oldRefreshToken},
      );

      final newAccessToken  = res.data!['access_token']  as String;
      final newRefreshToken = res.data!['refresh_token'] as String;

      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // 원래 요청 재시도 (별도 Dio로 인터셉터 재진입 방지)
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await Dio().fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // 갱신 실패 시 토큰 삭제 → 라우터 리다이렉트로 로그인 화면 이동
      await _storage.clearTokens();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
