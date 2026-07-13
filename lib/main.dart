import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/core/config/initial_uri.dart';
import 'package:fe_app/core/firebase/firebase_bootstrap.dart';
import 'package:fe_app/app.dart';

Future<void> main() async {
  // OAuth 콜백 토큰은 URL fragment(#access_token=...)에만 실려 오고, GoRouter 초기
  // 리다이렉트가 이를 지울 수 있어 앱 시작 최초 시점(라우터 생성 전)에 캡처해 둔다.
  final initialUri = Uri.base;

  WidgetsFlutterBinding.ensureInitialized();
  // 웹: OAuth 콜백 토큰이 URL fragment(#access_token=...)로 오므로,
  // fragment를 라우팅에 쓰는 기본 해시 전략과 충돌하지 않도록 path 전략을 사용한다.
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await dotenv.load(fileName: '.env');
  EnvConfig.validate();
  await FirebaseBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [initialUriProvider.overrideWithValue(initialUri)],
      child: const App(),
    ),
  );
}
