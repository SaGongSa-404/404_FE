import 'package:fe_app/core/network/api_exception.dart';

Map<String, dynamic> parseProfileJsonMap(Object? data) {
  if (data is! Map) {
    throw const ApiException(
      message: '서버 응답이 비어 있거나 형식이 올바르지 않습니다.',
    );
  }
  final root = Map<String, dynamic>.from(data);
  for (final key in ['data', 'result', 'payload']) {
    final nested = root[key];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
  }
  return root;
}
