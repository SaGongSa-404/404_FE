import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/wishlist/providers/android_share_intent_provider.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistShareIntentAppShell extends ConsumerStatefulWidget {
  const WishlistShareIntentAppShell({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<WishlistShareIntentAppShell> createState() =>
      _WishlistShareIntentAppShellState();
}

class _WishlistShareIntentAppShellState
    extends ConsumerState<WishlistShareIntentAppShell> {
  bool _flushScheduled = false;
  bool _isHandlingShare = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(androidShareIntentProvider.notifier).start();
      _flushPendingShare();
    });
  }

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      if (!mounted) return;
      _flushPendingShare();
    });
  }

  bool _canHandleShare(AsyncValue<UserModel?> authState) {
    if (authState.isLoading || authState.hasError) return false;
    if (EnvConfig.isDevXUserIdAuth) return true;
    return authState.valueOrNull?.onboardingStatus == 'COMPLETED';
  }

  void _flushPendingShare() {
    if (_isHandlingShare) return;

    final sharedLink = ref.read(androidShareIntentProvider);
    if (sharedLink == null || sharedLink.isEmpty) return;

    if (!_canHandleShare(ref.read(authProvider))) return;

    _isHandlingShare = true;
    ref.read(androidShareIntentProvider.notifier).consume();
    widget.router.go('/wishlist');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isHandlingShare = false;
      if (!mounted) return;
      ref
          .read(wishlistViewModelProvider.notifier)
          .openAddPanelWithLink(sharedLink);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(androidShareIntentProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _scheduleFlush();
      }
    });

    ref.listen<AsyncValue<UserModel?>>(authProvider, (previous, next) {
      _scheduleFlush();
    });

    return widget.child;
  }
}
