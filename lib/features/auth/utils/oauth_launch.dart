import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 네이티브 OAuth 콜백 딥링크 (백엔드 redirect_uri 와 동일해야 함).
const kMobileOAuthRedirectUri = 'sagongsa404://auth/callback';

/// 웹 OAuth 콜백 경로. 앱이 서빙되는 오리진 기준으로 동적 생성한다.
/// 이 URL은 백엔드 redirect_uri 화이트리스트 + 카카오/구글 콘솔에도 등록되어야 한다.
const kWebOAuthCallbackPath = '/auth/callback';

/// 플랫폼별 OAuth redirect_uri.
/// - 웹: `https://<현재 오리진>/auth/callback`
/// - 네이티브: 커스텀 스킴 딥링크
String oauthRedirectUri() {
  if (kIsWeb) return '${Uri.base.origin}$kWebOAuthCallbackPath';
  return kMobileOAuthRedirectUri;
}

/// iOS SFSafariViewController(inAppBrowserView)는 커스텀 스킴 리다이렉트를
/// 앱으로 넘기지 못하는 경우가 많아, iOS는 외부 Safari를 사용합니다.
LaunchMode oauthLaunchMode() {
  if (kIsWeb) return LaunchMode.platformDefault;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return LaunchMode.externalApplication;
  }
  return LaunchMode.inAppBrowserView;
}
