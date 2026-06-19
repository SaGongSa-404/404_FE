import 'dart:async';

import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/models/fcm_message_payload.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/providers/notification_settings_provider.dart';
import 'package:fe_app/features/notification/services/notification_router.dart';
import 'package:fe_app/features/notification/services/notification_service.dart';
import 'package:fe_app/shared/enums/api_enums.dart';
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
    StateNotifierProvider<NotificationLiveNotifier, NotificationLiveState>(
        (ref) {
  return NotificationLiveNotifier(
    ref.read(notificationServiceProvider),
    ref,
  );
});

class NotificationLiveNotifier extends StateNotifier<NotificationLiveState> {
  NotificationLiveNotifier(this._service, this._ref)
      : super(const NotificationLiveState.empty());

  final NotificationService _service;
  final Ref _ref;
  Timer? _timer;
  bool _started = false;
  bool _disposed = false;
  bool _initialized = false;
  final Set<String> _seenIds = <String>{};
  final Set<String> _seenVotePostIds = <String>{};

  static const Duration _pollInterval = Duration(seconds: 30);
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
    await sync(queueNewBanners: true);
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    pause();
    _started = false;
    _initialized = false;
    _seenIds.clear();
    _seenVotePostIds.clear();
    state = const NotificationLiveState.empty();
  }

  bool get _notificationsEnabled {
    final settings = _ref.read(notificationSettingsProvider);
    return settings.enabled;
  }

  Future<void> sync({required bool queueNewBanners}) async {
    if (_disposed) return;
    state = state.copyWith(isSyncing: true);

    try {
      final fetched = await _service.fetchNotifications(unreadOnly: false);
      final cutoff = DateTime.now().subtract(const Duration(days: _expireDays));
      final fresh = fetched
          .where((item) =>
              item.createdAt == null || item.createdAt!.isAfter(cutoff))
          .toList(growable: false)
        ..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      final newIds = fresh.map((e) => e.id).toList(growable: false);
      final shouldQueue =
          queueNewBanners && _initialized && _notificationsEnabled;
      final batchVotePostIds = <String>{};
      final newlyArrived = shouldQueue
          ? fresh
              .where((item) => !_seenIds.contains(item.id))
              .where((item) => _shouldQueueBanner(
                    item,
                    batchVotePostIds: batchVotePostIds,
                  ))
              .toList(growable: false)
          : const <NotificationModel>[];

      _seenIds
        ..clear()
        ..addAll(newIds);

      for (final item in fresh) {
        final postId = NotificationRouter.extractPostId(item);
        if (postId != null) {
          _seenVotePostIds.add(postId);
        }
      }

      state = state.copyWith(
        items: fresh,
        bannerQueue: [...state.bannerQueue, ...newlyArrived],
        isSyncing: false,
      );
      _initialized = true;

      if (newlyArrived.isNotEmpty) {
        unawaited(_ref.read(homeSummaryProvider.notifier).refresh());
      }
    } catch (error, stackTrace) {
      debugPrint('notification live sync failed: $error\n$stackTrace');
      state = state.copyWith(isSyncing: false);
    }
  }

  bool _shouldQueueBanner(
    NotificationModel item, {
    Set<String>? batchVotePostIds,
    bool fromPush = false,
  }) {
    if (item.isRead) return false;

    final type = NotificationType.fromApiValue(item.type);

    // 폴링으로 감지한 알림은 기획 §2 인앱 알림(투표/댓글/리마인드)만 배너 노출.
    // FCM foreground 수신은 OS 푸시 대체이므로 타입 제한 없이 노출(기획 §1).
    if (!fromPush && (type == null || !type.isInAppRealtime)) {
      return false;
    }

    if (type?.isSocialVoteBannerType == true) {
      final postId = NotificationRouter.extractPostId(item);
      if (postId != null) {
        if (_seenVotePostIds.contains(postId)) return false;
        if (batchVotePostIds != null) {
          if (batchVotePostIds.contains(postId)) return false;
          batchVotePostIds.add(postId);
        }
      }
    }

    return true;
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

  void syncItemsFrom(List<NotificationModel> source) {
    final sourceById = {
      for (final item in source) item.id: item,
    };
    _seenIds.addAll(sourceById.keys);

    NotificationModel mergeReadState(NotificationModel item) {
      final sourceItem = sourceById[item.id];
      if (sourceItem == null) {
        return item;
      }
      return sourceItem;
    }

    final updatedQueue = [
      for (final item in state.bannerQueue) mergeReadState(item),
    ];

    state = state.copyWith(items: source, bannerQueue: updatedQueue);
  }

  void consumeBanner(String id) {
    state = state.copyWith(
      bannerQueue: state.bannerQueue
          .where((item) => item.id != id)
          .toList(growable: false),
    );
  }

  /// FCM foreground 수신 시 인앱 배너 큐에 추가합니다.
  Future<void> enqueueFromPush(FcmMessagePayload payload) async {
    if (_disposed || !_notificationsEnabled) return;

    final notificationId = payload.notificationId;
    if (notificationId != null &&
        notificationId.isNotEmpty &&
        _seenIds.contains(notificationId)) {
      return;
    }

    NotificationModel? matched;
    if (notificationId != null && notificationId.isNotEmpty) {
      for (final item in state.items) {
        if (item.id == notificationId) {
          matched = item;
          break;
        }
      }
    }

    final candidate = matched ??
        NotificationModel(
          id: notificationId ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          title: payload.title ?? '',
          body: payload.body,
          time: '방금 전',
          isRead: false,
          targetPath: payload.targetPath ?? '',
          type: payload.type,
          itemId: payload.itemId,
          decisionId: payload.decisionId,
          reminderId: payload.reminderId,
          createdAt: DateTime.now(),
        );

    if (!_shouldQueueBanner(candidate, fromPush: true)) return;

    if (notificationId != null && notificationId.isNotEmpty) {
      _seenIds.add(notificationId);
    }

    final votePostId = NotificationRouter.extractPostId(candidate);
    if (votePostId != null) {
      _seenVotePostIds.add(votePostId);
    }

    state = state.copyWith(
      bannerQueue: [...state.bannerQueue, candidate],
    );

    unawaited(sync(queueNewBanners: false));
    unawaited(_ref.read(homeSummaryProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
