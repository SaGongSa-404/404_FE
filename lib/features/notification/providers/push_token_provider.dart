import 'dart:async';

import 'package:fe_app/core/firebase/firebase_bootstrap.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/notification/services/push_token_lifecycle.dart';
import 'package:fe_app/features/notification/services/fcm_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인/온보딩 완료 시 FCM 토큰 등록, 로그아웃 시 비활성화.
final pushTokenLifecycleProvider = Provider<void>((ref) {
  // 웹은 FCM 미지원(서비스워커/VAPID 미구성)이라 푸시 토큰 라이프사이클을 돌리지 않는다.
  if (kIsWeb) return;

  final fcm = ref.watch(fcmServiceProvider);

  ref.listen<AsyncValue>(authProvider, (previous, next) {
    final wasAuthed = previous?.hasValue == true && previous?.value != null;
    final isAuthed = next.hasValue && next.value != null;
    final completed = next.value?.onboardingStatus == 'COMPLETED';

    if (isAuthed && completed) {
      unawaited(_bootstrapFcm(fcm));
      unawaited(fcm.syncForAuthenticatedUser());
      return;
    }

    if (wasAuthed && !isAuthed) {
      unawaited(deactivateStoredPushTokenWithReader(ref.read));
    }
  });

  if (FirebaseBootstrap.isInitialized) {
    unawaited(_bootstrapFcm(fcm));
    final auth = ref.read(authProvider);
    if (auth.hasValue &&
        auth.value != null &&
        auth.value!.onboardingStatus == 'COMPLETED') {
      unawaited(fcm.syncForAuthenticatedUser());
    }
  }
});

Future<void> _bootstrapFcm(FcmService fcm) async {
  await fcm.start();
}
