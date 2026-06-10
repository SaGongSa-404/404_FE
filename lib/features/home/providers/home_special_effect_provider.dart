import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class HomeSpecialEffectState {
  final ConsiderCaseType? caseType;
  final VideoPlayerController? preloadedController;

  const HomeSpecialEffectState({
    this.caseType,
    this.preloadedController,
  });

  bool get hasPendingSpecial =>
      caseType != null && preloadedController != null;
}

class HomeSpecialEffectNotifier extends StateNotifier<HomeSpecialEffectState> {
  HomeSpecialEffectNotifier() : super(const HomeSpecialEffectState());

  String _baseNameForCase(ConsiderCaseType caseType) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
      case ConsiderCaseType.caseC:
        return 'nugul_just_smile';
      case ConsiderCaseType.caseB:
        return 'nugul_rainy';
      case ConsiderCaseType.caseD:
        return 'nugul_more_excited';
    }
  }

  Future<void> preloadCase(ConsiderCaseType caseType) async {
    final existing = state.preloadedController;
    if (state.caseType == caseType &&
        existing != null &&
        existing.value.isInitialized &&
        !existing.value.hasError) {
      return;
    }

    await _disposePreloadedController();

    final baseName = _baseNameForCase(caseType);
    final controller = await createVideoAssetController(baseName, loop: false);

    state = HomeSpecialEffectState(
      caseType: caseType,
      preloadedController: controller,
    );
  }

  /// HomeScreen이 재생을 시작할 때 provider 소유권을 넘깁니다.
  VideoPlayerController? takePreloadedController() {
    final controller = state.preloadedController;
    if (controller == null) return null;

    state = const HomeSpecialEffectState();
    return controller;
  }

  void detachController(VideoPlayerController controller) {
    if (state.preloadedController == controller) {
      state = const HomeSpecialEffectState();
    }
  }

  Future<void> _disposePreloadedController() async {
    final controller = state.preloadedController;
    state = const HomeSpecialEffectState();

    if (controller != null) {
      await controller.dispose();
    }
  }

  void resetAfterPlay() {
    state = const HomeSpecialEffectState();
  }
}

final homeSpecialEffectProvider =
    StateNotifierProvider<HomeSpecialEffectNotifier, HomeSpecialEffectState>(
  (ref) => HomeSpecialEffectNotifier(),
);
