import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_comment_request.freezed.dart';
part 'create_comment_request.g.dart';

@freezed
class CreateCommentRequest with _$CreateCommentRequest {
  const CreateCommentRequest._();

  const factory CreateCommentRequest({
    required String body,
  }) = _CreateCommentRequest;

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);

  static const int maxBodyLength = 300;

  factory CreateCommentRequest.fromCompose({required String body}) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('body must not be empty');
    }
    if (trimmed.length > maxBodyLength) {
      throw ArgumentError('body must be at most $maxBodyLength characters');
    }
    return CreateCommentRequest(body: trimmed);
  }

  Map<String, dynamic> toApiJson() => {'body': body};
}
