import 'package:flutter_riverpod/flutter_riverpod.dart';

/// GoRouter 준비 전(스플래시/인증 redirect)에 도착한 알림 경로를 보관합니다.
final pendingNotificationRouteProvider =
    StateProvider<String?>((ref) => null);
