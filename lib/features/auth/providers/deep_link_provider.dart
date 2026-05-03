import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';

part 'deep_link_provider.g.dart';

@Riverpod(keepAlive: true)
class DeepLinkHandler extends _$DeepLinkHandler {
  static const _scheme = 'sagongsa404';
  static const _host   = 'auth';
  static const _path   = '/callback';

  @override
  void build() => _init();

  Future<void> _init() async {
    final appLinks = AppLinks();

    // allUriLinkStream: 앱 콜드스타트 초기 링크 + 이후 수신 링크를 모두 포함
    appLinks.allUriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == _scheme &&
        uri.host == _host &&
        uri.path == _path) {
      ref.read(authProvider.notifier).handleCallback(uri);
    }
  }
}
