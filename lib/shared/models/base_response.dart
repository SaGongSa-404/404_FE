// [예시] 공통 API 응답 래퍼

class BaseResponse<T> {
  const BaseResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
  });

  final bool success;
  final T? data;
  final String? message;
  final String? code;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool? ?? false,
      // 예시 — 다른 스키마
      // success: (json['status'] as String?) == 'OK',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'message': message,
      'code': code,
    };
  }
}
