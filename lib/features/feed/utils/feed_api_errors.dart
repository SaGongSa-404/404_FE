import 'package:fe_app/core/network/api_exception.dart';

String feedCreatePostErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      403 => '게시글을 작성할 수 없어요.',
      404 => '연결한 위시 상품을 찾을 수 없어요.',
      _ => api.message,
    };
  }
  return '게시글을 등록하지 못했어요. 잠시 후 다시 시도해 주세요.';
}

String feedListErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      _ => api.message,
    };
  }
  return '피드를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
}

String feedDetailErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api?.statusCode == 404) {
    return '삭제되었거나 볼 수 없는 게시글이에요.';
  }
  return api?.message ?? '게시글을 불러오지 못했어요.';
}

String feedCommentErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      404 => '댓글을 작성할 수 없는 게시글이에요.',
      _ => api.message,
    };
  }
  return '댓글을 등록하지 못했어요. 잠시 후 다시 시도해 주세요.';
}

String feedReportErrorMessage(Object error) {
  final api = apiExceptionFrom(error);
  if (api != null) {
    return switch (api.statusCode) {
      400 => api.message,
      403 => '이미 신고했거나 신고할 수 없어요.',
      404 => '신고 대상을 찾을 수 없어요.',
      _ => api.message,
    };
  }
  return '신고를 접수하지 못했어요. 잠시 후 다시 시도해 주세요.';
}
