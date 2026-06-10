import 'package:dio/dio.dart';
import 'package:fe_app/core/network/api_exception.dart';

const String kRestrictedAccountMessage = '이용이 제한된 계정입니다.';

bool isRestrictedAccountError(Object? error) {
  if (error == null) return false;
  if (error is DioException && error.response?.statusCode == 403) {
    return true;
  }
  final api = apiExceptionFrom(error);
  return api?.statusCode == 403;
}
