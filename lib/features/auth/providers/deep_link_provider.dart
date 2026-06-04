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
