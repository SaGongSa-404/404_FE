import 'package:dio/dio.dart';
import 'package:fe_app/core/network/api_exception.dart';

Map<String, dynamic> requireJsonMapBody(
  Response<Map<String, dynamic>> response, {
  String message = '서버 응답 형식이 올바르지 않습니다.',
}) {
  final data = response.data;
  if (data is Map<String, dynamic>) return data;
  throw ApiException(
    message: message,
    statusCode: response.statusCode,
    responseData: data,
  );
}
