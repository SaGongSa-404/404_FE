import 'package:fe_app/features/wishlist/models/item_import/item_import_link_response.dart';

enum ShoppingImportJobStatus {
  pending,
  running,
  succeeded,
  failed;

  static ShoppingImportJobStatus fromApiValue(String value) {
    return switch (value) {
      'PENDING' => ShoppingImportJobStatus.pending,
      'RUNNING' => ShoppingImportJobStatus.running,
      'SUCCEEDED' => ShoppingImportJobStatus.succeeded,
      'FAILED' => ShoppingImportJobStatus.failed,
      _ => throw FormatException('Unknown shopping import status: $value'),
    };
  }
}

class ShoppingImportJobAccepted {
  const ShoppingImportJobAccepted({
    required this.jobId,
    required this.status,
    required this.submittedAt,
  });

  final String jobId;
  final ShoppingImportJobStatus status;
  final DateTime? submittedAt;

  factory ShoppingImportJobAccepted.fromJson(Map<String, dynamic> json) {
    return ShoppingImportJobAccepted(
      jobId: json['jobId'] as String,
      status: ShoppingImportJobStatus.fromApiValue(json['status'] as String),
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
    );
  }
}

class ShoppingImportJobError {
  const ShoppingImportJobError({required this.code, required this.message});

  final String code;
  final String message;

  factory ShoppingImportJobError.fromJson(Map<String, dynamic> json) {
    return ShoppingImportJobError(
      code: json['code'] as String? ?? 'IMPORT_FAILED',
      message: json['message'] as String? ?? '상품 정보를 가져오지 못했어요.',
    );
  }
}

class ShoppingImportJobResult {
  const ShoppingImportJobResult({
    required this.jobId,
    required this.status,
    required this.attemptCount,
    this.result,
    this.error,
    this.submittedAt,
    this.startedAt,
    this.completedAt,
  });

  final String jobId;
  final ShoppingImportJobStatus status;
  final ItemImportLinkResponse? result;
  final ShoppingImportJobError? error;
  final int attemptCount;
  final DateTime? submittedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  factory ShoppingImportJobResult.fromJson(Map<String, dynamic> json) {
    final resultJson = json['result'];
    final errorJson = json['error'];

    return ShoppingImportJobResult(
      jobId: json['jobId'] as String,
      status: ShoppingImportJobStatus.fromApiValue(json['status'] as String),
      result: resultJson is Map<String, dynamic>
          ? ItemImportLinkResponse.fromJson(resultJson)
          : null,
      error: errorJson is Map<String, dynamic>
          ? ShoppingImportJobError.fromJson(errorJson)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
      submittedAt: _date(json['submittedAt']),
      startedAt: _date(json['startedAt']),
      completedAt: _date(json['completedAt']),
    );
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
