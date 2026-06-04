import 'package:flutter/foundation.dart';

/// OAuth 콜백 딥링크 URI 판별·토큰 파싱.
bool isOAuthCallbackUri(Uri uri) {
  if (uri.scheme != 'sagongsa404') return false;

  final host = uri.host.toLowerCase();
  if (host != 'auth') return false;

  final path = uri.path;
  if (path.isEmpty || path == '/') return true;
  if (path == '/callback' || path == 'callback') return true;
  return path.endsWith('/callback');
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
