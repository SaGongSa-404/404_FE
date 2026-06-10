import 'dart:async';

import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/providers/notification_navigation_provider.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:fe_app/features/notification/services/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FCM 초기화 및 인증 상태에 따른 토큰 등록/비활성화.
final fcmLifecycleProvider = Provider<void>((ref) {
  ref.keepAlive();
  final service = ref.watch(fcmServiceProvider);
  var initialized = false;
  var initializing = false;

  Future<void> syncAuthState(AsyncValue authState) async {
    if (!authState.hasValue) return;

    if (!initialized && !initializing) {
      initializing = true;
      initialized = await service.initialize();
      initializing = false;
      if (!initialized) return;

      service.onForegroundMessage = (message) async {
        await ref.read(notificationLiveProvider.notifier).sync(queueNewBanners: true);
      };
      service.onPushOpened = (_) {
        ref.read(pendingNotificationRouteProvider.notifier).state = '/notifications';
        unawaited(ref.read(notificationListProvider(false).notifier).refresh());
      };
    }

    if (!initialized) return;

    final user = authState.value;
    final canRegister =
        user != null && user.onboardingStatus == 'COMPLETED';

    if (canRegister) {
      await service.registerWithBackend();
    } else if (user == null) {
      await service.deactivateRegisteredToken();
    }
  }

  unawaited(syncAuthState(ref.read(authProvider)));
  ref.listen<AsyncValue>(authProvider, (previous, next) {
    unawaited(syncAuthState(next));
  });
});
