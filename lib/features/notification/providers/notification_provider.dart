import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/services/notification_service.dart';

class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationListNotifier(this._ref, this._service, this._unreadOnly)
      : super(const AsyncLoading()) {
    unawaited(load());
  }

  final Ref _ref;
  final NotificationService _service;
  final bool _unreadOnly;
  CancelToken? _cancelToken;

  Future<void> load({bool showLoading = true}) async {
    _cancelToken?.cancel('reload');
    final token = CancelToken();
    _cancelToken = token;

    if (showLoading || state.valueOrNull == null) {
      state = const AsyncLoading();
    }
    try {
      final items = await _service.fetchNotifications(
        unreadOnly: _unreadOnly,
        cancelToken: token,
      );
      if (token.isCancelled) return;
      state = AsyncData(_sortAndFilterExpired(items));
    } catch (error, stackTrace) {
      if (token.isCancelled) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh({bool showLoading = true}) =>
      load(showLoading: showLoading);

  /// 읽음 처리. 404이면 만료/삭제된 알림으로 보고 목록에서 제거합니다.
  Future<MarkAsReadResult> markAsRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return MarkAsReadResult.failed;

    final result = await _service.markAsRead(id, cancelToken: _cancelToken);

    if (result == MarkAsReadResult.notFound) {
      final updated = current.where((notification) => notification.id != id).toList(growable: false);
      state = AsyncData(updated);
      _invalidateHomeSummary();
      return result;
    }

    if (result != MarkAsReadResult.success) return result;

    final updated = _unreadOnly
        ? current.where((notification) => notification.id != id).toList(growable: false)
        : [
            for (final notification in current)
              if (notification.id == id)
                notification.copyWith(isRead: true, readAt: DateTime.now())
              else
                notification,
          ];
    state = AsyncData(updated);
    _invalidateHomeSummary();
    return result;
  }

  void _invalidateHomeSummary() {
    unawaited(_ref.read(homeSummaryProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }
}

final notificationListProvider = StateNotifierProvider.family<
    NotificationListNotifier, AsyncValue<List<NotificationModel>>, bool>((ref, unreadOnly) {
  return NotificationListNotifier(
    ref,
    ref.watch(notificationServiceProvider),
    unreadOnly,
  );
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final liveItems = ref.watch(notificationLiveProvider).items;
  if (liveItems.isNotEmpty) {
    return liveItems.where((notification) => !notification.isRead).length;
  }

  return ref.watch(notificationListProvider(false)).when(
        data: (items) => items.where((notification) => !notification.isRead).length,
        loading: () => 0,
        error: (_, __) => 0,
      );
});

List<NotificationModel> _sortAndFilterExpired(List<NotificationModel> items) {
  final cutoff = DateTime.now().subtract(const Duration(days: 30));
  final filtered = items
      .where((item) => item.createdAt == null || item.createdAt!.isAfter(cutoff))
      .toList(growable: false)
    ..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  return filtered;
}
