import 'package:dio/dio.dart';

String parseApiErrorMessage(Object? data, {String? fallback}) {
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;

    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error != null) return error.toString();

    final title = data['title'];
    if (title is String && title.isNotEmpty) return title;
  } else if (data is String && data.isNotEmpty) {
    return data;
  }

  return fallback ?? '요청을 처리하지 못했습니다.';
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.responseData,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? responseData;

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    final data = response?.data;
    final code = data is Map<String, dynamic> ? data['code']?.toString() : null;

    return ApiException(
      message: parseApiErrorMessage(
        data,
        fallback: error.message ?? '네트워크 오류가 발생했습니다.',
      ),
      statusCode: response?.statusCode,
      code: code,
      responseData: data,
    );
  }

  @override
  String toString() => message;
}
