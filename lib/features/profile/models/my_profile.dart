class MyProfile {
  const MyProfile({
    required this.id,
    required this.nickname,
    required this.provider,
    required this.status,
    this.onboardingStatus,
    this.postCount = 0,
    this.createdAt,
  });

  final String id;
  final String nickname;
  final String provider;
  final String status;
  final String? onboardingStatus;
  final int postCount;
  final DateTime? createdAt;

  factory MyProfile.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final postCountRaw = json['postCount'];
    return MyProfile(
      id: (json['id'] ?? json['userId'])?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? json['name']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      onboardingStatus: json['onboardingStatus']?.toString(),
      postCount: postCountRaw is int
          ? postCountRaw
          : int.tryParse(postCountRaw?.toString() ?? '') ?? 0,
      createdAt: createdAtRaw is String ? DateTime.tryParse(createdAtRaw) : null,
    );
  }

  bool get isValid => id.isNotEmpty && nickname.isNotEmpty;

  MyProfile copyWith({
    String? nickname,
    String? provider,
    String? status,
    String? onboardingStatus,
    int? postCount,
  }) {
    return MyProfile(
      id: id,
      nickname: nickname ?? this.nickname,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt,
    );
  }
}
