import 'dart:async';

import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationLiveState {
  const NotificationLiveState({
    required this.items,
    required this.bannerQueue,
    required this.isSyncing,
  });

  final List<NotificationModel> items;
  final List<NotificationModel> bannerQueue;
  final bool isSyncing;

  const NotificationLiveState.empty()
      : items = const [],
        bannerQueue = const [],
        isSyncing = false;

  NotificationLiveState copyWith({
    List<NotificationModel>? items,
    List<NotificationModel>? bannerQueue,
    bool? isSyncing,
  }) {
    return NotificationLiveState(
      items: items ?? this.items,
      bannerQueue: bannerQueue ?? this.bannerQueue,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

final notificationLiveProvider =
    StateNotifierProvider<NotificationLiveNotifier, NotificationLiveState>((ref) {
  return NotificationLiveNotifier(ref.read(notificationServiceProvider));
});

class NotificationLiveNotifier extends StateNotifier<NotificationLiveState> {
  NotificationLiveNotifier(this._service) : super(const NotificationLiveState.empty());

  final NotificationService _service;
  Timer? _timer;
  bool _started = false;
  bool _disposed = false;
  bool _initialized = false;
  final Set<String> _seenIds = <String>{};

  static const Duration _pollInterval = Duration(seconds: 5);
  static const int _expireDays = 30;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await sync(queueNewBanners: false);
    _timer = Timer.periodic(_pollInterval, (_) => sync(queueNewBanners: true));
  }

  Future<void> resume() async {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => sync(queueNewBanners: true));
    await sync(queueNewBanners: false);
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> sync({required bool queueNewBanners}) async {
    if (_disposed) return;
    state = state.copyWith(isSyncing: true);

    try {
      final fetched = await _service.fetchNotifications(unreadOnly: false);
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: _expireDays));
      final fresh = fetched
          .where((item) => item.createdAt == null || item.createdAt!.isAfter(cutoff))
          .toList(growable: false)
        ..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      final newIds = fresh.map((e) => e.id).toList(growable: false);
      final shouldQueue = queueNewBanners && _initialized;
      final newlyArrived = shouldQueue
          ? fresh.where((item) => !_seenIds.contains(item.id)).toList(growable: false)
          : const <NotificationModel>[];

      _seenIds
        ..clear()
        ..addAll(newIds);

      final mergedQueue = <NotificationModel>[
        ...state.bannerQueue,
        ...newlyArrived,
      ];

      state = state.copyWith(
        items: fresh,
        bannerQueue: mergedQueue,
        isSyncing: false,
      );
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('notification live sync failed: $error\n$stackTrace');
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> markAsRead(String id, {bool syncRemote = true}) async {
    if (syncRemote) {
      try {
        await _service.markAsRead(id);
      } catch (error, stackTrace) {
        debugPrint('notification markAsRead failed: $error\n$stackTrace');
      }
    }

    final updatedItems = [
      for (final item in state.items)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
    final updatedQueue = [
      for (final item in state.bannerQueue)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
    state = state.copyWith(items: updatedItems, bannerQueue: updatedQueue);
  }

  void consumeBanner(String id) {
    state = state.copyWith(
      bannerQueue: state.bannerQueue.where((item) => item.id != id).toList(growable: false),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
