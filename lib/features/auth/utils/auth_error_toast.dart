import 'package:fe_app/core/router/app_router.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/auth/utils/auth_error.dart';
import 'package:fe_app/shared/widgets/capsule_toast.dart';
import 'package:flutter/scheduler.dart';

class RestrictedAccountToast {
  RestrictedAccountToast._();

  static void scheduleShow() {
    SchedulerBinding.instance.addPostFrameCallback((_) => show());
  }

  static void show() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showCapsuleToast(
      context,
      backgroundColor: AppColors.red_600.withValues(alpha: 0.8),
      text: kRestrictedAccountMessage,
    );
  }
}
