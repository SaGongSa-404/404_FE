import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fe_app/features/feed/models/vote_type.dart';

part 'vote_request.freezed.dart';
part 'vote_request.g.dart';

@freezed
class VoteRequest with _$VoteRequest {
  const factory VoteRequest({
    required VoteType voteType,
  }) = _VoteRequest;

  factory VoteRequest.fromJson(Map<String, dynamic> json) =>
      _$VoteRequestFromJson(json);
}
