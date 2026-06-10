class TokenRefreshResponse {
  const TokenRefreshResponse({
    required this.tokenType,
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String tokenType;
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: _parseInstant(json['accessTokenExpiresAt']),
      refreshTokenExpiresAt: _parseInstant(json['refreshTokenExpiresAt']),
    );
  }

  static DateTime? _parseInstant(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
