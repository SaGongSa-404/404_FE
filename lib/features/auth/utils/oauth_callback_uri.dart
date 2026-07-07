import 'package:fe_app/features/auth/models/user.dart';
import 'package:flutter/foundation.dart';

/// OAuth 콜백 딥링크 URI 판별·토큰 파싱.
bool isOAuthCallbackUri(Uri uri) {
  // 네이티브: 커스텀 스킴 딥링크 (sagongsa404://auth/callback)
  if (uri.scheme == 'sagongsa404') {
    final host = uri.host.toLowerCase();
    if (host != 'auth') return false;

    final path = uri.path;
    if (path.isEmpty || path == '/') return true;
    if (path == '/callback' || path == 'callback') return true;
    return path.endsWith('/callback');
  }

  // 웹: https://<origin>/auth/callback (토큰이 실제로 실려 있을 때만 콜백으로 인정)
  if (kIsWeb && (uri.scheme == 'http' || uri.scheme == 'https')) {
    final path = uri.path;
    final isCallbackPath =
        path == '/auth/callback' || path.endsWith('/auth/callback');
    if (!isCallbackPath) return false;

    final params = readOAuthCallbackParams(uri);
    return params.containsKey('access_token') ||
        params.containsKey('refresh_token');
  }

  return false;
}

Map<String, String> readOAuthCallbackParams(Uri uri) {
  if (uri.fragment.isNotEmpty) {
    try {
      final fromFragment = Uri.splitQueryString(uri.fragment);
      if (fromFragment.containsKey('access_token') ||
          fromFragment.containsKey('refresh_token')) {
        return fromFragment;
      }
    } on FormatException {
      if (kDebugMode) {
        debugPrint('[oauth] fragment parse failed, falling back to query');
      }
    }
  }
  return uri.queryParameters;
}

UserModel? userModelFromOAuthCallbackParams(Map<String, String> params) {
  final userId = params['user_id']?.trim();
  final provider = params['provider']?.trim();
  final providerUserId = params['provider_user_id']?.trim();
  final name = params['name']?.trim();
  if (userId == null ||
      userId.isEmpty ||
      provider == null ||
      provider.isEmpty ||
      providerUserId == null ||
      providerUserId.isEmpty ||
      name == null ||
      name.isEmpty) {
    return null;
  }

  final email = params['email']?.trim();
  final profileImageUrl = params['profile_image_url']?.trim();

  return UserModel(
    authenticated: true,
    userId: userId,
    provider: provider,
    providerUserId: providerUserId,
    name: name,
    email: email != null && email.isNotEmpty ? email : null,
    profileImageUrl:
        profileImageUrl != null && profileImageUrl.isNotEmpty
            ? profileImageUrl
            : null,
    principalName: name,
    authorities: const [],
    onboardingStatus: null,
  );
}

/// 디버그 로그용 — 토큰·민감 쿼리는 포함하지 않습니다.
String describeOAuthCallbackUri(Uri uri) {
  final hasFragment = uri.fragment.isNotEmpty;
  final queryKeys = uri.queryParameters.keys.toList(growable: false);
  final fragmentLooksLikeTokens = hasFragment &&
      (uri.fragment.contains('access_token') ||
          uri.fragment.contains('refresh_token'));
  return '${uri.scheme}://${uri.host}${uri.path}'
      ' (fragment=$hasFragment, fragmentHasTokens=$fragmentLooksLikeTokens, '
      'queryKeys=$queryKeys)';
}
