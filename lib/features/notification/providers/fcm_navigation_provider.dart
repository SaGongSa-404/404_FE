import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FCM/푸시 탭 시 알림 목록 화면으로 이동해야 함을 알리는 신호.
final fcmNavigationProvider =
    StateNotifierProvider<FcmNavigationNotifier, bool>(
  (ref) => FcmNavigationNotifier(),
);

class FcmNavigationNotifier extends StateNotifier<bool> {
  FcmNavigationNotifier() : super(false);

  void requestOpenNotificationsPage() {
    state = true;
  }

  void consume() {
    state = false;
  }
}
