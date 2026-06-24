import 'package:fe_app/features/notification/providers/notification_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

bool _isOpeningNotificationsPage = false;

/// 알림 화면 진입 전 목록·홈 요약을 새로고침하고 이동합니다.
Future<void> openNotificationsPage(
  WidgetRef ref,
  BuildContext context,
) async {
  if (_isOpeningNotificationsPage) return;
  _isOpeningNotificationsPage = true;

  await ref.read(notificationSyncProvider).refreshListAndHomeSummary();
  if (!context.mounted) {
    _isOpeningNotificationsPage = false;
    return;
  }

  final router = GoRouter.of(context);
  if (router.state.uri.path == '/notifications') {
    _isOpeningNotificationsPage = false;
    return;
  }

  try {
    await context.push('/notifications');
  } finally {
    _isOpeningNotificationsPage = false;
  }
}
