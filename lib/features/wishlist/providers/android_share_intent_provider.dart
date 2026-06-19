import 'dart:async';

import 'package:fe_app/features/wishlist/utils/share_link_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidShareIntentProvider =
    StateNotifierProvider<AndroidShareIntentNotifier, String?>(
  (ref) => AndroidShareIntentNotifier(),
);

class AndroidShareIntentNotifier extends StateNotifier<String?> {
  AndroidShareIntentNotifier() : super(null);

  static const _methodChannel = MethodChannel('wigul/share_intent');
  static const _eventChannel = EventChannel('wigul/share_intent/events');
  static final _urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);
  StreamSubscription<dynamic>? _sharedTextSubscription;
  bool _started = false;

  void start() {
    if (_started || defaultTargetPlatform != TargetPlatform.android) return;
    _started = true;
    unawaited(_init());
  }

  Future<void> _init() async {
    _sharedTextSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is String) {
          _handleSharedText(event);
        }
      },
      onError: (_) {
        // 공유 이벤트 스트림 오류는 일반 앱 실행 흐름에 영향을 주지 않습니다.
      },
    );

    try {
      final initialText = await _methodChannel.invokeMethod<String>(
        'getInitialSharedText',
      );
      _handleSharedText(initialText);
    } on MissingPluginException {
      return;
    } on PlatformException {
      // 공유 인텐트 수신 실패는 일반 앱 실행 흐름에 영향을 주지 않습니다.
    }
  }

  void _handleSharedText(String? text) {
    final link = _extractFirstShareLink(text);
    if (link == null) return;
    state = link;
  }

  void consume() {
    state = null;
  }

  static String? _extractFirstShareLink(String? text) {
    final value = text?.trim();
    if (value == null || value.isEmpty) return null;

    final direct = ShareLinkUrl.normalize(value);
    if (direct != null) return direct;

    final match = _urlPattern.firstMatch(value);
    if (match == null) return null;

    final rawUrl = match.group(0)?.replaceAll(RegExp(r'[)\].,]+$'), '');
    return ShareLinkUrl.normalize(rawUrl ?? '');
  }

  @override
  void dispose() {
    unawaited(_sharedTextSubscription?.cancel());
    super.dispose();
  }
}
