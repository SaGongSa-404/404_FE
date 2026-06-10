import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/providers/home_bubble_provider.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:fe_app/features/home/services/home_bubble_engine.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_info_container.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:fe_app/shared/widgets/main_tab_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _PendingVideoSyncRequest {
  const _PendingVideoSyncRequest({
    required this.defaultVideoBaseName,
    required this.hasSpecial,
  });

  final String defaultVideoBaseName;
  final bool hasSpecial;
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const _balloonDuration = Duration(seconds: 3);

  final PageController _pageController = PageController();
  VideoPlayerController? _videoController;
  int _currentPage = 0;
  String _currentVideoPath = '';
  String _currentVideoBaseName = 'nugul_home';
  bool _isPlayingSpecialOnce = false;
  bool _isInitializing = false;
  _PendingVideoSyncRequest? _pendingSyncRequest;
  bool _hasUserInteractedWithMascot = false;
  VoidCallback? _specialListener;
  Timer? _balloonDismissTimer;
  String? _visibleBalloonMessage;
  HomeBubbleType? _visibleBubbleType;
  bool _hasHandledBubbleRuntime = false;
  bool _isShowingBubble = false;
  bool _isRefreshing = false;

  String _getDefaultVideoBaseName(bool isBudgetExhausted) {
    return isBudgetExhausted ? 'nugul_budget_left_0' : 'nugul_home';
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

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _cleanupOldController();

      setState(() {
        _videoController = controller;
        _currentVideoPath = controller.dataSource;
        _currentVideoBaseName = baseName;
      });

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
  }) {
    _pendingSyncRequest = _PendingVideoSyncRequest(
      defaultVideoBaseName: defaultVideoBaseName,
      hasSpecial: hasSpecial,
    );
  }

  void _tryDrainPendingSyncRequest() {
    if (!mounted || _isInitializing || _isPlayingSpecialOnce) return;

    final pending = _pendingSyncRequest;
    if (pending == null) return;

    _pendingSyncRequest = null;
    _syncVideoPlayback(
      defaultVideoBaseName: pending.defaultVideoBaseName,
      hasSpecial: pending.hasSpecial,
    );
  }

  Future<void> _cleanupOldController() async {
    final controller = _videoController;
    if (controller == null) return;

    if (_specialListener != null) {
      controller.removeListener(_specialListener!);
      _specialListener = null;
    }

    ref.read(homeSpecialEffectProvider.notifier).detachController(controller);
    await controller.dispose();
    _videoController = null;
  }

  Future<void> _restoreDefaultVideo(String defaultVideoBaseName) async {
    _isPlayingSpecialOnce = false;
    if (!mounted) return;
    await _initializeVideo(defaultVideoBaseName, loop: true);
  }

  Future<void> _playPreloadedSpecialAndRestore({
    required String defaultVideoBaseName,
  }) async {
    if (_isPlayingSpecialOnce || _isInitializing) {
      _storePendingSyncRequest(
        defaultVideoBaseName: defaultVideoBaseName,
        hasSpecial: true,
      );
      return;
    }

    final preloadedController = ref
        .read(homeSpecialEffectProvider.notifier)
        .takePreloadedController();
    if (preloadedController == null) {
      _syncVideoPlayback(
        defaultVideoBaseName: defaultVideoBaseName,
        hasSpecial: false,
      );
      return;
    }

    if (!preloadedController.value.isInitialized ||
        preloadedController.value.hasError) {
      await preloadedController.dispose();
      await _restoreDefaultVideo(defaultVideoBaseName);
      return;
    }

    _isPlayingSpecialOnce = true;

    final oldController = _videoController;
    if (oldController != null && _specialListener != null) {
      oldController.removeListener(_specialListener!);
      _specialListener = null;
    }

    if (!mounted) {
      _isPlayingSpecialOnce = false;
      await preloadedController.dispose();
      return;
    }

    try {
      await preloadedController.setLooping(false);
      await preloadedController.seekTo(Duration.zero);

      setState(() {
        _videoController = preloadedController;
        _currentVideoPath = preloadedController.dataSource;
      });

      await preloadedController.play();

      if (oldController != null && oldController != preloadedController) {
        ref
            .read(homeSpecialEffectProvider.notifier)
            .detachController(oldController);
        unawaited(oldController.dispose());
      }
    } catch (error, stackTrace) {
      debugPrint('Special video playback failed: $error\n$stackTrace');
      await _cleanupOldController();
      await _restoreDefaultVideo(defaultVideoBaseName);
      return;
    }

    var alreadyFinished = false;

    void onTick() {
      if (alreadyFinished || !mounted || _videoController != preloadedController) {
        preloadedController.removeListener(onTick);
        return;
      }

      final value = preloadedController.value;
      if (!value.isInitialized) return;

      if (value.hasError) {
        alreadyFinished = true;
        preloadedController.removeListener(onTick);
        _specialListener = null;
        unawaited(_cleanupOldController().then((_) {
          if (mounted) {
            unawaited(_restoreDefaultVideo(defaultVideoBaseName));
          }
        }));
        return;
      }

      final duration = value.duration;
      if (duration <= Duration.zero) return;

      final remaining = duration - value.position;
      final reachedEnd = remaining <= const Duration(milliseconds: 200);
      if (!reachedEnd) return;

     _