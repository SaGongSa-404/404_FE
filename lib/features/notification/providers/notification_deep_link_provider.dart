import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fe_app/features/notification/models/notification_route_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationDeepLinkProvider =
    StateNotifierProvider<NotificationDeepLinkNotifier, NotificationRouteIntent?>(
  (ref) => NotificationDeepLinkNotifier(ref),
);

class NotificationDeepLinkNotifier extends StateNotifier<NotificationRouteIntent?> {
  NotificationDeepLinkNotifier(this._ref) : super(null) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<Uri>? _subscription;

  static const _scheme = 'sagongsa404';
  static const _host = 'notify';

  Future<void> _init() async {
    final appLinks = AppLinks();
    await _subscription?.cancel();
    try {
      final initial = await appLinks.getInitialAppLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (_) {}
    _subscription = appLinks.allUriLinkStream.listen(_handleUri);
    _ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != _scheme || uri.host != _host) return;
    state = NotificationRouteIntent.fromUri(uri);
  }

  void consume() {
    state = null;
  }
}


