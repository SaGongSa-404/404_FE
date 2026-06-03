import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// OAuth 콜백 딥링크 (백엔드 redirect_uri 와 동일해야 함).
const kOAuthRedirectUri = 'sagongsa404://auth/callback';

/// iOS SFSafariViewController(inAppBrowserView)는 커스텀 스킴 리다이렉트를
/// 앱으로 넘기지 못하는 경우가 많아, iOS는 외부 Safari를 사용합니다.
LaunchMode oauthLaunchMode() {
  if (kIsWeb) return LaunchMode.platformDefault;
  if (!kIsWeb && Platform.isIOS) return LaunchMode.externalApplication;
  return LaunchMode.inAppBrowserView;
}
