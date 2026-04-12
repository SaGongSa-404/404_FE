import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 엔드포인트 상수 사용 시 주석 해제
// import 'package:fe_app/core/network/api_endpoints.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  final Dio _dio;

  static Dio _createDefaultDio() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;

  // 예시 — Bearer 토큰 등
  // void attachAuthToken(String token) {
  //   _dio.options.headers['Authorization'] = 'Bearer $token';
  // }

  // 예시 — POST (ApiEndpoints에 경로 정의 후)
  // Future<Response<dynamic>> postJson(String path, {Object? data}) =>
  //     _dio.post<dynamic>(path, data: data);
}
