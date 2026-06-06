import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class HomeSpecialEffectState {
  final ConsiderCaseType? caseType;
  final VideoPlayerController? preloadedController;
  final String? preloadedPath;

  const HomeSpecialEffectState({
    this.caseType,
    this.preloadedController,
    this.preloadedPath,
  });

  HomeSpecialEffectState copyWith({
    ConsiderCaseType? caseType,
    VideoPlayerController? preloadedController,
    String? preloadedPath,
    bool clearController = false,
  }) {
    return HomeSpecialEffectState(
      caseType: caseType ?? this.caseType,
      preloadedController:
      clearController ? null : (preloadedController ?? this.preloadedController),
      preloadedPath:
      clearController ? null : (preloadedPath ?? this.preloadedPath),
    );
  }
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
    if (state.caseType == caseType && state.preloadedController != null) return;

    await clearPreloadedController();

    final baseName = _baseNameForCase(caseType);
    final controller = await createVideoAssetController(baseName, loop: false);
    final path = controller.dataSource;

    state = HomeSpecialEffectState(
      caseType: caseType,
      preloadedController: controller,
      preloadedPath: path,
    );
  }

  void markCase(ConsiderCaseType caseType) {
    state = state.copyWith(caseType: caseType);
  }

  Future<void> clearPreloadedController() async {
    final controller = state.preloadedController;

    state = state.copyWith(
      caseType: null,
      clearController: true,
    );

    if (controller != null) {
      await controller.dispose();
    }
  }

  void resetAfterPlay() {
    state = const HomeSpecialEffectState();
  }
}

final homeSpecialEffectProvider =
StateNotifierProvider<HomeSpecialEffectNotifier, HomeSpecialEffectState>((ref) {
  return HomeSpecialEffectNotifier();
});