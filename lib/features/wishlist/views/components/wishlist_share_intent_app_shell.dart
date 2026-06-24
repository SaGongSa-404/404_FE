import 'package:fe_app/features/wishlist/providers/wishlist_share_intent_coordinator_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(wishlistShareIntentCoordinatorProvider.notifier).start();
    });
  }

  void _openShareAfterNavigation(String sharedLink) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(wishlistShareIntentCoordinatorProvider.notifier)
          .openPendingShare(sharedLink);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(wishlistShareIntentCoordinatorProvider, (_, next) {
      if (next == null || next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.router.go('/wishlist');
        _openShareAfterNavigation(next);
      });
    });

    return widget.child;
  }
}
