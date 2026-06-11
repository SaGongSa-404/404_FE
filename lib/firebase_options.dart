import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase 프로젝트 설정.
///
/// `flutterfire configure` 실행 후 이 파일을 덮어쓰거나,
/// `.env`에 Firebase 값을 넣어 사용할 수 있습니다.
abstract final class DefaultFirebaseOptions {
  static bool get isConfigured {
    final androidAppId = _readEnv('FIREBASE_ANDROID_APP_ID');
    final iosAppId = _readEnv('FIREBASE_IOS_APP_ID');
    return (androidAppId != null && androidAppId.isNotEmpty) ||
        (iosAppId != null && iosAppId.isNotEmpty);
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web Firebase is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _requireEnv('FIREBASE_ANDROID_API_KEY'),
        appId: _requireEnv('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _requireEnv('FIREBASE_PROJECT_ID'),
        storageBucket: _optionalEnv('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _requireEnv('FIREBASE_IOS_API_KEY'),
        appId: _requireEnv('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _requireEnv('FIREBASE_PROJECT_ID'),
        storageBucket: _optionalEnv('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: _optionalEnv('FIREBASE_IOS_BUNDLE_ID') ?? 'com.example.feApp',
      );

  static String _requireEnv(String key) {
    final value = _readEnv(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        '$key is required for Firebase. '
        'Run `flutterfire configure` or set Firebase values in .env.',
      );
    }
    return value;
  }

  static String? _optionalEnv(String key) => _readEnv(key);

  static String? _readEnv(String key) {
    final value = dotenv.env[key]?.trim();
    return value != null && value.isNotEmpty ? value : null;
  }
}
