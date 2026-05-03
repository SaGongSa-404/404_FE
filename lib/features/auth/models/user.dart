import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String provider,         // 'kakao' | 'google'
    required String providerUserId,   // 소셜 제공자 고유 ID
    required String name,
    String? email,                    // 카카오는 null 가능
    String? profileImageUrl,          // 소셜 설정에 따라 null 가능
    required String principalName,
    required List<String> authorities,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
