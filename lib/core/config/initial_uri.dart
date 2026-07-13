import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시점의 URL.
///
/// 웹 OAuth 콜백은 토큰이 URL fragment(#access_token=...)로 실려 오는데,
/// GoRouter 초기 리다이렉트가 fragment를 지워버리기 전에 [main]에서 `Uri.base`를
/// 캡처해 이 provider로 주입한다. (`main.dart`에서 override)
final initialUriProvider = Provider<Uri>((_) => Uri.base);
