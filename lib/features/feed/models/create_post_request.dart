import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_request.freezed.dart';
part 'create_post_request.g.dart';

@freezed
class CreatePostRequest with _$CreatePostRequest {
  const CreatePostRequest._();

  const factory CreatePostRequest({
    String? title,
    String? body,
    String? imageUrl,
    int? price,
    String? itemId,
  }) = _CreatePostRequest;

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePostRequestFromJson(json);

  static const int maxTitleLength = 140;
  static const int maxBodyLength = 500;

  factory CreatePostRequest.fromCompose({
    String? title,
    String? body,
    String? imageUrl,
    int? price,
    String? itemId,
  }) {
    final trimmedTitle = title?.trim();
    final trimmedBody = body?.trim();
    final trimmedImageUrl = imageUrl?.trim();
    final trimmedItemId = itemId?.trim();

    if (trimmedTitle != null && trimmedTitle.length > maxTitleLength) {
      throw ArgumentError('title must be at most $maxTitleLength characters');
    }
    if (trimmedBody != null && trimmedBody.length > maxBodyLength) {
      throw ArgumentError('body must be at most $maxBodyLength characters');
    }
    if (price != null && price < 0) {
      throw ArgumentError('price must be greater than or equal to 0');
    }

    return CreatePostRequest(
      title: trimmedTitle?.isEmpty == true ? null : trimmedTitle,
      body: trimmedBody?.isEmpty == true ? null : trimmedBody,
      imageUrl: trimmedImageUrl?.isEmpty == true ? null : trimmedImageUrl,
      price: price,
      itemId: trimmedItemId?.isEmpty == true ? null : trimmedItemId,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
      if (itemId != null) 'itemId': itemId,
    };
  }
}
