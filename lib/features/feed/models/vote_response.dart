import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fe_app/features/feed/models/vote_type.dart';

part 'vote_response.freezed.dart';
part 'vote_response.g.dart';

@freezed
class VoteResponse with _$VoteResponse {
  const factory VoteResponse({
    VoteType? myVote,
    @Default(0) int goCount,
    @Default(0) int stopCount,
  }) = _VoteResponse;

  factory VoteResponse.fromJson(Map<String, dynamic> json) =>
      _$VoteResponseFromJson(json);
}
