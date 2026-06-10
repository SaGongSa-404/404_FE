import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_request.freezed.dart';
part 'report_request.g.dart';

@freezed
class ReportRequest with _$ReportRequest {
  const ReportRequest._();

  const factory ReportRequest({
    required String category,
    String? reason,
  }) = _ReportRequest;

  factory ReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestFromJson(json);

  static const int maxReasonLength = 100;
  static const String otherCategory = 'OTHER';

  factory ReportRequest.fromSubmission({
    required String category,
    String? reason,
  }) {
    final trimmedCategory = category.trim().toUpperCase();
    final trimmedReason = reason?.trim();

    if (trimmedCategory.isEmpty) {
      throw ArgumentError('category must not be empty');
    }
    if (trimmedCategory == otherCategory &&
        (trimmedReason == null || trimmedReason.isEmpty)) {
      throw ArgumentError('reason is required when category is OTHER');
    }
    if (trimmedReason != null && trimmedReason.length > maxReasonLength) {
      throw ArgumentError(
        'reason must be at most $maxReasonLength characters',
      );
    }

    return ReportRequest(
      category: trimmedCategory,
      reason: trimmedReason?.isEmpty == true ? null : trimmedReason,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'category': category,
      if (reason != null) 'reason': reason,
    };
  }
}
