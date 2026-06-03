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
    final fromFragment = Uri.splitQueryString(uri.fragment);
    if (fromFragment.containsKey('access_token') ||
        fromFragment.containsKey('refresh_token')) {
      return fromFragment;
    }
  }
  return uri.queryParameters;
}
