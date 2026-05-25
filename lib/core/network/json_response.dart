import 'package:fe_app/core/network/api_exception.dart';

Map<String, dynamic> requireJsonMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  throw const ApiException(
    message: '서버 응답이 비어 있거나 형식이 올바르지 않습니다.',
  );
}
