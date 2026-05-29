import 'package:json_annotation/json_annotation.dart';

enum VoteType {
  @JsonValue('GO')
  go,
  @JsonValue('STOP')
  stop,
}
