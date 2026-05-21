import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/features/tutorial/views/wishlist_tutorial_screen.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';

/// 위시 담기 튜토리얼 1·2단계를 한 경로(`/tutorial`)에서 진행합니다.
class WishlistTutorialRouteScreen extends ConsumerStatefulWidget {
  const WishlistTutorialRouteScreen({
    super.key,
    this.restoreAddEntryModalOnExit = false,
  });

  final bool restoreAddEntryModalOnExit;

  @override
  ConsumerState<WishlistTutorialRouteScreen> createState() =>
      _WishlistTutorialRouteScreenState();
}

class _WishlistTutorialRouteScreenState
    extends ConsumerState<WishlistTutorialRouteScreen> {
  static const _totalSteps = 2;

  int _currentStep = 1;

  void _goToStep2() => setState(() => _currentStep = 2);

  void _finish() {
    if (widget.restoreAddEntryModalOnExit) {
      ref.read(wishlistViewModelProvider.notifier).requestReopenAddEntryModal();
    }
    context.go('/wishlist');
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep = 1);
      return;
    }
    if (widget.restoreAddEntryModalOnExit) {
      ref.read(wishlistViewModelProvider.notifier).requestReopenAddEntryModal();
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/wishlist');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 1) {
      return WishlistTutorialScreen(
        key: const ValueKey<int>(1),
        currentStep: 1,
        totalSteps: _totalSteps,
        restoreAddEntryModalOnExit: false,
        label: '위시템 담기 1',
        titleWhilePlaying: '구매하고 싶은 아이템의\n링크를 공유해주세요',
        titleAfterPlay: '위굴 아이콘을 누르면\n저장 완료!',
        videoAsset: 'assets/videos/wishlist_demo.mp4',
        buttonLabel: '다음',
        onBack: _handleBack,
        onComplete: _goToStep2,
      );
    }

    return WishlistTutorialScreen(
      key: const ValueKey<int>(2),
      currentStep: 2,
      totalSteps: _totalSteps,
      restoreAddEntryModalOnExit: false,
      label: '위시템 담기 2',
      titleWhilePlaying: '구매하고 싶은 아이템의\n링크를 복사해주세요',
      titleAfterPlay: '링크를 붙여넣으면\n저장 완료!',
      videoAsset: 'assets/videos/wishlist_demo_2.mp4',
      buttonLabel: '닫기',
      onBack: _handleBack,
      onComplete: _finish,
    );
  }
}
