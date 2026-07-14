import 'dart:async';

import 'package:fe_app/features/notification/providers/notification_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

bool _isOpeningNotificationsPage = false;

/// 알림 화면을 먼저 열고, 목록·홈 요약은 화면 안에서 새로고침합니다.
Future<void> openNotificationsPage(
  WidgetRef ref,
  BuildContext context,
) async {
  if (_isOpeningNotificationsPage) return;
  _isOpeningNotificationsPage = true;

  try {
    if (!context.mounted) return;

    final router = GoRouter.of(context);
    if (router.state.uri.path == '/notifications') return;

    unawaited(context.push('/notifications'));
    unawaited(ref.read(notificationSyncProvider).refreshListAndHomeSummary());
  } catch (_) {
    // Keep notification entry best-effort; the tap guard is released below.
  } finally {
    _isOpeningNotificationsPage = false;
  }
}
