import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super(_mockNotifications);

  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: '00님이 투표를 했어요',
      time: '2분 전',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: '구매 후 후회하고 있진 않나요?\n기록하러 가기',
      time: '5분 전',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'ㅁㅁ님이 댓글을 달았어요',
      time: '10분 전',
      isRead: true,
    ),
  ];

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true),
    ];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
