import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 알림 화면 진입 전 목록·홈 요약을 새로고침하고 이동합니다.
Future<void> openNotificationsPage(
  WidgetRef ref,
  BuildContext context,
) async {
  await ref.read(notificationListProvider(false).notifier).refresh();
  await ref.read(homeSummaryProvider.notifier).refresh();
  if (!context.mounted) return;
  context.push('/notifications');
}
