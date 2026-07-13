import 'package:dio/dio.dart';
import 'package:fe_app/core/platform/io_platform.dart';

const String kNetworkErrorMessage = '인터넷 연결을 확인해 주세요';

bool isNetworkError(Object? error) {
  if (error is DioException) {
    return _isDioNetworkError(error);
  }
  if (isSocketException(error)) {
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
      return isSocketException(error.error);
    default:
      return false;
  }
}
