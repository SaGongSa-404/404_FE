import 'dart:io';

import 'package:dio/dio.dart';

const String kNetworkErrorMessage = '인터넷 연결을 확인해 주세요';

bool isNetworkError(Object? error) {
  if (error is DioException) {
    return _isDioNetworkError(error);
  }
  if (error is SocketException) {
    return true;
  }
  return false;
}

bool _isDioNetworkError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.unknown:
      return error.error is SocketException;
    default:
      return false;
  }
}
