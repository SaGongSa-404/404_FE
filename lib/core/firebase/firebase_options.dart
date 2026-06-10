import 'package:fe_app/core/config/env_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// `.env`의 Firebase 값으로 [FirebaseOptions]를 구성합니다.
abstract final class AppFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (!EnvConfig.isFirebaseConfigured) return null;

    if (kIsWeb) {
      return _options;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _options;
      default:
        return null;
    }
  }

  static FirebaseOptions get _options {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey!,
      appId: EnvConfig.firebaseAppId!,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId!,
      projectId: EnvConfig.firebaseProjectId!,
      storageBucket: EnvConfig.firebaseStorageBucket,
      iosBundleId: EnvConfig.firebaseIosBundleId,
    );
  }
}
