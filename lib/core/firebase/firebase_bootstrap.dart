import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Core 초기화. 설정이 없으면 no-op.
abstract final class FirebaseBootstrap {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    final options = AppFirebaseOptions.currentPlatform;
    if (options == null) {
      if (kDebugMode) {
        debugPrint(
          '[firebase] FIREBASE_* env not set — FCM disabled. '
          'See .env.example',
        );
      }
      return;
    }

    await Firebase.initializeApp(options: options);
    _initialized = true;
    if (kDebugMode) {
      debugPrint('[firebase] initialized (project=${options.projectId})');
    }
  }
}
