abstract final class ApiEndpoints {
  static const String _basePath = '/api';

  // OAuth 소셜 로그인 URL 생성 (url_launcher로 외부 브라우저에서 호출)
  static String oauthAuthorization(String provider, String redirectUri) =>
      '/oauth2/authorization/$provider?redirect_uri=$redirectUri';

  // 인증
  static const String me           = '$_basePath/auth/me';
  static const String tokenRefresh = '$_basePath/auth/token/refresh';
  static const String logout       = '$_basePath/logout';
}
