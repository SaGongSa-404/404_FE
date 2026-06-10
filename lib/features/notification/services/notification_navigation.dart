import 'dart:async';

import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 알림 페이지 진입·복귀 네비게이션 헬퍼.
abstract final class NotificationNavigation {
  static const notificationsPath = '/notifications';
  static const returnToParam = 'returnTo';

  /// 알림 상세 이동 후 뒤로가기 시 알림 페이지로 복귀하도록 쿼리를 붙입니다.
  static String withReturnTo(String route) {
    final uri = Uri.parse(route.startsWith('/') ? route : '/$route');
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      returnToParam: notificationsPath,
    }).toString();
  }

  static String? returnToPath(GoRouterState state) {
    return state.uri.queryParameters[returnToParam];
  }

  /// 알림 페이지에서 진입한 상세 화면의 뒤로가기 처리.
  static void popOrReturn(BuildContext context) {
    final returnTo = GoRouterState.of(context).uri.queryParameters[returnToParam];
    if (returnTo != null && returnTo.isNotEmpty) {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go(returnTo);
      return;
    }

    if (context.canPop()) {
      context.pop();
    }
  }

  /// [returnTo] 쿼리가 있을 때 시스템 뒤로가기를 알림 페이지 복귀로 연결합니다.
  static Widget wrapWithBackHandler(BuildContext context, Widget child) {
    final returnTo = returnToPath(GoRouterState.of(context));
    if (returnTo == null) return child;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          popOrReturn(context);
        }
      },
      child: child,
    );
  }

  /// 알림 아이콘 탭 시 목록을 새로고침한 뒤 알림 페이지로 이동합니다.
  static Future<void> openNotificationScreen(
    BuildContext context,
    WidgetRef ref,
  ) async {
    unawaited(
      ref.read(notificationListProvider(false).notifier).refresh(showLoading: false),
    );
    unawaited(ref.read(homeSummaryProvider.notifier).refresh());
    if (!context.mounted) return;
    await context.push(notificationsPath);
  }
}
