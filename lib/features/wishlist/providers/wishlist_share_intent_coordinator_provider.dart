import 'package:fe_app/core/config/env_config.dart';
import 'package:fe_app/features/auth/models/user.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/wishlist/providers/android_share_intent_provider.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistShareIntentCoordinatorProvider =
    StateNotifierProvider<WishlistShareIntentCoordinator, String?>((ref) {
  final coordinator = WishlistShareIntentCoordinator(ref);
  ref.listen<String?>(
    androidShareIntentProvider,
    (_, __) => coordinator.flushPendingShare(),
  );
  ref.listen<AsyncValue<UserModel?>>(
    authProvider,
    (_, __) => coordinator.flushPendingShare(),
  );
  return coordinator;
});

class WishlistShareIntentCoordinator extends StateNotifier<String?> {
  WishlistShareIntentCoordinator(this._ref) : super(null);

  final Ref _ref;
  bool _isHandlingShare = false;

  void start() {
    _ref.read(androidShareIntentProvider.notifier).start();
    flushPendingShare();
  }

  void flushPendingShare() {
    if (_isHandlingShare || state != null) return;

    final sharedLink = _ref.read(androidShareIntentProvider);
    if (sharedLink == null || sharedLink.isEmpty) return;

    if (!_canHandleShare(_ref.read(authProvider))) return;

    _isHandlingShare = true;
    _ref.read(androidShareIntentProvider.notifier).consume();
    state = sharedLink;
  }

  void openPendingShare(String sharedLink) {
    if (state != sharedLink) return;

    state = null;
    _isHandlingShare = false;
    _ref
        .read(wishlistViewModelProvider.notifier)
        .openAddPanelWithLink(sharedLink);
  }

  bool _canHandleShare(AsyncValue<UserModel?> authState) {
    if (authState.isLoading || authState.hasError) return false;
    if (EnvConfig.isDevXUserIdAuth) return true;
    return authState.valueOrNull?.onboardingStatus == 'COMPLETED';
  }
}
