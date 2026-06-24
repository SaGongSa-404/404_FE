import 'package:fe_app/core/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Core 초기화. 설정이 없으면 no-op.
abstract final class FirebaseBootstrap {
  static bool _initialized = false;
  static Future<void>? _initializingFuture;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() {
    if (_initialized) return Future.value();
    return _initializingFuture ??= _performInitialize().whenComplete(() {
      _initializingFuture = null;
    });
  }

  static Future<void> _performInitialize() async {
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

    try {
      await Firebase.initializeApp(options: options);
      _initialized = true;
      if (kDebugMode) {
        debugPrint('[firebase] initialized (project=${options.projectId})');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[firebase] initialization failed: $error\n$stackTrace');
      }
    }
  }
}
