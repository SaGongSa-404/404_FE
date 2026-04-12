// 진입점. `.env`는 없어도 실행되며, API 주소는 [ApiClient]에서 빈 문자열로 둘 수 있습니다.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fe_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env 없이도 실행 가능 (API_BASE_URL 등은 기본값 사용)
  }
  runApp(const App());
}
