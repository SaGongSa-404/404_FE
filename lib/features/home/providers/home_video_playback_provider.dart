import 'dart:async';

import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class _PendingVideoSyncRequest {
  const _PendingVideoSyncRequest({
    required this.defaultVideoBaseName,
    required this.hasSpecial,
    this.preloadedController,
  });

  final String defaultVideoBaseName;
  final bool hasSpecial;
  final VideoPlayerController? preloadedController;
}

/// 홈 누굴 비디오 재생 오케스트레이션.
/// 컨트롤러 수명 관리, 스페셜 영상 1회 재생, 재생 중 들어온 동기화 요청 큐잉을 담당한다.
class HomeVideoPlaybackController extends ChangeNotifier {
  HomeVideoPlaybackController({required this.onSpecialEffectPlayed});

  /// 스페셜 영상 재생 완료 후 호출 (homeSpecialEffectProvider 초기화용).
  final VoidCallback onSpecialEffectPlayed;

  VideoPlayerController? _videoController;
  String _currentVideoPath = '';
  String _currentVideoBaseName = 'nugul_home';
  bool _isPlayingSpecialOnce = false;
  bool _isInitializing = false;
  bool _disposed = false;
  _PendingVideoSyncRequest? _pendingSyncRequest;
  VoidCallback? _specialListener;

  VideoPlayerController? get videoController => _videoController;
  String get currentVideoPath => _currentVideoPath;

  void replayFromStart() {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  void sync({
    required String defaultVideoBaseName,
    required bool hasSpecial,
    required VideoPlayerController? preloadedController,
  }) {
    if (_disposed) return;

    if (_isPlayingSpecialOnce || _isInitializing) {
      _storePendingSyncRequest(
        defaultVideoBaseName: defaultVideoBaseName,
        hasSpecial: hasSpecial,
        preloadedController: preloadedController,
      );
      return;
    }

    if (hasSpecial && preloadedController != null) {
      unawaited(
        _playPreloadedSpecialAndRestore(
          preloadedController: preloadedController,
          defaultVideoBaseName: defaultVideoBaseName,
        ),
      );
      return;
    }

    if (_currentVideoBaseName != defaultVideoBaseName ||
        _videoController == null) {
      unawaited(_initializeVideo(defaultVideoBaseName, loop: true));
    }
  }

  Future<void> _initializeVideo(String baseName, {bool loop = true}) async {
    if (_isInitializing) return;

    if (_currentVideoBaseName == baseName &&
        _videoController != null &&
        _videoController!.value.isInitialized &&
        !_isPlayingSpecialOnce) {
      return;
    }

    _isInitializing = true;
    try {
      final controller = await createVideoAssetController(baseName, loop: loop);

      if (_disposed) {
        await controller.dispose();
        return;
      }

      await _cleanupOldController();

      _videoController = controller;
      _currentVideoPath = controller.dataSource;
      _currentVideoBaseName = baseName;
      notifyListeners();

      await controller.play();
    } catch (e) {
      debugPrint('Video initialization error: $e');
    } finally {
      _isInitializing = false;
      _tryDrainPendingSyncRequest();
    }
  }

  void _storePendingSyncRequest({
    required String defaultVideoBaseName,
    required bool hasSpecial,
    required VideoPlayerController? preloadedController,
  }) {
    _pendingSyncRequest = _PendingVideoSyncRequest(
      defaultVideoBaseName: defaultVideoBaseName,
      hasSpecial: hasSpecial,
      preloadedController: preloadedController,
    );
  }

  void _tryDrainPendingSyncRequest() {
    if (_disposed || _isInitializing || _isPlayingSpecialOnce) return;

    final pending = _pendingSyncRequest;
    if (pending == null) return;

    _pendingSyncRequest = null;
    sync(
      defaultVideoBaseName: pending.defaultVideoBaseName,
      hasSpecial: pending.hasSpecial,
      preloadedController: pending.preloadedController,
    );
  }

  Future<void> _cleanupOldController() async {
    if (_videoController != null) {
      if (_specialListener != null) {
        _videoController!.removeListener(_specialListener!);
        _specialListener = null;
      }
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  Future<void> _playPreloadedSpecialAndRestore({
    required VideoPlayerController preloadedController,
    required String defaultVideoBaseName,
  }) async {
    if (_isPlayingSpecialOnce) {
      _storePendingSyncRequest(
        defaultVideoBaseName: defaultVideoBaseName,
        hasSpecial: true,
        preloadedController: preloadedController,
      );
      return;
    }
    _isPlayingSpecialOnce = true;

    final oldController = _videoController;
    if (oldController != null && _specialListener != null) {
      oldController.removeListener(_specialListener!);
      _specialListener = null;
    }

    if (_disposed) return;

    await preloadedController.setLooping(false);
    await preloadedController.seekTo(Duration.zero);

    _videoController = preloadedController;
    _currentVideoPath = preloadedController.dataSource;
    notifyListeners();

    await preloadedController.play();

    if (oldController != null) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => oldController.dispose(),
      );
    }

    // 영상의 개수를 비교하여 한 번만 재생되도록 처리
    bool alreadyReturned = false;

    void onTick() async {
      if (alreadyReturned ||
          _disposed ||
          _videoController != preloadedController) {
        preloadedController.removeListener(onTick);
        return;
      }

      final value = preloadedController.value;
      if (!value.isInitialized || value.duration <= Duration.zero) return;

      // 정확한 종료 감지: position이 duration과 거의 같을 때
      // (duration - 100ms 이내)
      final remainingMs =
          value.duration.inMilliseconds - value.position.inMilliseconds;

      if (remainingMs <= 100 && !value.isPlaying) {
        alreadyReturned = true;
        preloadedController.removeListener(onTick);
        _specialListener = null;

        onSpecialEffectPlayed();

        if (_disposed) return;

        await _initializeVideo(defaultVideoBaseName, loop: true);
        _isPlayingSpecialOnce = false;
        _tryDrainPendingSyncRequest();
      }
    }

    _specialListener = onTick;
    preloadedController.addListener(onTick);
  }

  @override
  void dispose() {
    _disposed = true;
    if (_videoController != null && _specialListener != null) {
      _videoController!.removeListener(_specialListener!);
    }
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }
}

final homeVideoPlaybackProvider =
    ChangeNotifierProvider.autoDispose<HomeVideoPlaybackController>((ref) {
  final controller = HomeVideoPlaybackController(
    onSpecialEffectPlayed: () =>
        ref.read(homeSpecialEffectProvider.notifier).resetAfterPlay(),
  );

  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    controller.dispose();
  });

  String defaultVideoBaseName() {
    final record = ref.read(consumptionStatsProvider).currentMonthStats;
    final remaining =
        record == null ? 1 : record.budgetAmount - record.spentAmount;
    final isExhausted = record != null && remaining <= 0;
    return isExhausted ? 'nugul_budget_left_0' : 'nugul_home';
  }

  // 프레임 빌드 중 notifyListeners가 발생하지 않도록 다음 프레임으로 미룬다.
  void scheduleSyncWithCurrentState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (disposed) return;
      final special = ref.read(homeSpecialEffectProvider);
      controller.sync(
        defaultVideoBaseName: defaultVideoBaseName(),
        hasSpecial:
            special.caseType != null && special.preloadedController != null,
        preloadedController: special.preloadedController,
      );
    });
  }

  ref.listen(
      homeSpecialEffectProvider, (_, __) => scheduleSyncWithCurrentState());
  ref.listen(
      consumptionStatsProvider, (_, __) => scheduleSyncWithCurrentState());

  // 최초 진입 시 기본 영상 재생.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (disposed) return;
    final special = ref.read(homeSpecialEffectProvider);
    controller.sync(
      defaultVideoBaseName: defaultVideoBaseName(),
      hasSpecial:
          special.caseType != null && special.preloadedController != null,
      preloadedController: special.preloadedController,
    );
  });

  return controller;
});
