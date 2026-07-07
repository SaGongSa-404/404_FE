import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/auth/utils/oauth_callback_uri.dart';

part 'deep_link_provider.g.dart';

@Riverpod(keepAlive: true)
class DeepLinkHandler extends _$DeepLinkHandler {
  @override
  void build() => _init();

  Future<void> _init() async {
    // 웹은 app_links 딥링크 스트림이 동작하지 않는다.
    // OAuth 콜백은 앱 로드 시점의 현재 URL(Uri.base)에 fragment/query로 실려 온다.
    // GoRouter가 URL을 바꾸기 전에 동기적으로 읽어야 하므로 await 이전에 처리한다.
    if (kIsWeb) {
      final initialUri = Uri.base;
      if (isOAuthCallbackUri(initialUri)) {
        _handleUri(initialUri);
      }
      return;
    }

    final appLinks = AppLinks();

    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {}

    appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (kDebugMode) {
      debugPrint('[deep_link] received: ${describeOAuthCallbackUri(uri)}');
    }
    if (isOAuthCallbackUri(uri)) {
      ref.read(authProvider.notifier).handleCallback(uri);
    }
  }
}
