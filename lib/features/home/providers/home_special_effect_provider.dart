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

  String _pathForCase(ConsiderCaseType caseType) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
        return 'assets/videos/nugul_sunny_smile.mp4';
      case ConsiderCaseType.caseB:
        return 'assets/videos/nugul_rainy.mp4';
      case ConsiderCaseType.caseC:
        return 'assets/videos/nugul_sunny_smile.mp4';
      case ConsiderCaseType.caseD:
        return 'assets/videos/nugul_sunny_happy.mp4';
    }
  }

  Future<void> preloadCase(ConsiderCaseType caseType) async {
    if (state.caseType == caseType && state.preloadedController != null) return;

    await clearPreloadedController();

    final path = _pathForCase(caseType);
    final controller = VideoPlayerController.asset(path);
    await controller.setVolume(0);
    await controller.initialize();
    controller.setLooping(false);

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