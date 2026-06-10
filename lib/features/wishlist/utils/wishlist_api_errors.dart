import 'package:fe_app/core/network/api_exception.dart';

String importLinkErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      422 => '상품 제목이나 가격 정보를 가져오지 못했어요.',
      502 => '쇼핑 페이지를 열지 못했어요. 잠시 후 다시 시도해 주세요.',
      _ => api.message,
    };
  }
  return '상품 정보를 가져오지 못했어요. 잠시 후 다시 시도해 주세요.';
}

String wishlistSaveErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      409 => '이미 담긴 상품이에요',
      _ => api.message,
    };
  }
  return '위시를 담지 못했어요. 잠시 후 다시 시도해 주세요.';
}
