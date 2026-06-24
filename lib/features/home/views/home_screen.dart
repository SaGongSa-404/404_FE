import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/home/domain/home_bubble_selector.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/providers/home_bubble_provider.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/home/services/home_summary_service.dart';
import 'package:fe_app/features/home/utils/home_summary_extensions.dart';
import 'package:fe_app/features/home/views/components/home_info_carousel.dart';
import 'package:fe_app/features/home/views/components/home_mascot_video.dart';
import 'package:fe_app/features/notification/utils/notification_navigation.dart';
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
  static const _balloonBackgroundOpacity = 0.5;
  static const _specialFinishLeadTime = Duration(milliseconds: 80);
  static const _specialDisposeDelay = Duration(seconds: 4);

  VideoPlayerController? _videoController;
  VideoPlayerController? _parkedDefaultController;
  VideoPlayerController? _pendingSpecialDispose;
  String _currentVideoBaseName = 'nugul_home';
  bool _isPlayingSpecialOnce = false;
  bool _isInitializing = false;
  _PendingVideoSyncRequest? _pendingSyncRequest;
  VoidCallback? _specialListener;
  Timer? _balloonDismissTimer;
  String? _visibleBalloonMessage;
  HomeBubbleType? _visibleBubbleType;
  bool _hasHandledBubbleRuntime = false;
  bool _hasHandledServerBubble = false;
  bool _isShowingBubble = false;
  bool _routeListenerAttached = false;
  String? _lastKnownRoutePath;
  VoidCallback? _routeListener;

  Future<void> _initializeVideo(String baseName, {bool loop = true}) async {
    if (_isInitializing) return;

    if (_currentVideoBaseName == baseName &&
        _videoController != null &&
        _videoController!.value.isInitialized &&
        !_videoController!.value.hasError) {
      return;
    }

    _isInitializing = true;
    try {
      final controller = await createVideoAssetController(baseName, loop: loop);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _disposeParkedDefault();
      await _disposePendingSpecial();
      await _cleanupActiveController();

      setState(() {
        _videoController = controller;
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

  Future<void> _disposeParkedDefault() async {
    final parked = _parkedDefaultController;
    _parkedDefaultController = null;
    if (parked != null) {
      await parked.dispose();
    }
  }

  Future<void> _disposePendingSpecial() async {
    final pending = _pendingSpecialDispose;
    _pendingSpecialDispose = null;
    if (pending != null) {
      await pending.dispose();
    }
  }

  void _scheduleSpecialDispose(VideoPlayerController controller) {
    final previous = _pendingSpecialDispose;
    _pendingSpecialDispose = controller;
    previous?.dispose();

    Future<void>.delayed(_specialDisposeDelay, () {
      if (_pendingSpecialDispose != controller) return;
      _pendingSpecialDispose = null;
      controller.dispose();
    });
  }

  void _detachSpecialListener(VideoPlayerController? controller) {
    if (controller != null && _specialListener != null) {
      controller.removeListener(_specialListener!);
    }
    _specialListener = null;
  }

  void _finishSpecialPlayback() {
    if (!_isPlayingSpecialOnce) return;

    final specialController = _videoController;
    final parkedDefault = _parkedDefaultController;
    _detachSpecialListener(specialController);
    _isPlayingSpecialOnce = false;
    _parkedDefaultController = null;

    if (parkedDefault != null &&
        parkedDefault.value.isInitialized &&
        !parkedDefault.value.hasError) {
      unawaited(parkedDefault.setLooping(true));
      unawaited(parkedDefault.play());
      if (mounted) {
        setState(() {
          _videoController = parkedDefault;
        });
      } else {
        _videoController = parkedDefault;
      }
    }

    if (specialController != null && specialController != parkedDefault) {
      unawaited(specialController.pause());
      _scheduleSpecialDispose(specialController);
    }
  }

  Future<void> _cleanupActiveController() async {
    final controller = _videoController;
    if (controller == null) return;

    _detachSpecialListener(controller);
    ref.read(homeSpecialEffectProvider.notifier).detachController(controller);
    await controller.dispose();
    _videoController = null;
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

    final preloadedController =
        ref.read(homeSpecialEffectProvider.notifier).takePreloadedController();
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
      return;
    }

    if (_videoController == null ||
        !_videoController!.value.isInitialized ||
        _videoController!.value.hasError ||
        _currentVideoBaseName != defaultVideoBaseName) {
      await _initializeVideo(defaultVideoBaseName, loop: true);
      if (!mounted) {
        await preloadedController.dispose();
        return;
      }
    }

    final defaultController = _videoController;
    if (defaultController == null || !defaultController.value.isInitialized) {
      await preloadedController.dispose();
      return;
    }

    if (!mounted) {
      await preloadedController.dispose();
      return;
    }

    try {
      await defaultController.pause();
      _parkedDefaultController = defaultController;

      await preloadedController.setLooping(false);
      await preloadedController.seekTo(Duration.zero);

      _isPlayingSpecialOnce = true;
      setState(() {
        _videoController = preloadedController;
      });

      await preloadedController.play();
    } catch (error, stackTrace) {
      debugPrint('Special video playback failed: $error\n$stackTrace');
      _isPlayingSpecialOnce = false;
      _parkedDefaultController = null;
      _videoController = defaultController;
      await preloadedController.dispose();
      if (mounted) setState(() {});
      unawaited(defaultController.setLooping(true));
      unawaited(defaultController.play());
      return;
    }

    var alreadyFinished = false;

    void onTick() {
      if (alreadyFinished ||
          !mounted ||
          _videoController != preloadedController) {
        preloadedController.removeListener(onTick);
        return;
      }

      final value = preloadedController.value;
      if (!value.isInitialized) return;

      if (value.hasError) {
        alreadyFinished = true;
        _finishSpecialPlayback();
        return;
      }

      final duration = value.duration;
      if (duration <= Duration.zero) return;

      final finishAt = duration - _specialFinishLeadTime;
      if (value.position < finishAt) return;

      alreadyFinished = true;
      _finishSpecialPlayback();
    }

    _specialListener = onTick;
    preloadedController.addListener(onTick);
  }

  void _syncVideoPlayback({
    required String defaultVideoBaseName,
    required bool hasSpecial,
  }) {
    if (!mounted) return;

    if (_isPlayingSpecialOnce || _isInitializing) {
      _storePendingSyncRequest(
        defaultVideoBaseName: defaultVideoBaseName,
        hasSpecial: hasSpecial,
      );
      return;
    }

    if (hasSpecial) {
      final specialState = ref.read(homeSpecialEffectProvider);
      if (specialState.hasPendingSpecial) {
        unawaited(
          _playPreloadedSpecialAndRestore(
            defaultVideoBaseName: defaultVideoBaseName,
          ),
        );
        return;
      }
    }

    final needsDefaultVideo = _videoController == null ||
        !_videoController!.value.isInitialized ||
        _videoController!.value.hasError ||
        _currentVideoBaseName != defaultVideoBaseName;

    if (needsDefaultVideo) {
      unawaited(_initializeVideo(defaultVideoBaseName, loop: true));
    }
  }

  void _onNugulTap() {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  Future<void> _refreshOnEntry({bool showCardLoading = false}) async {
    _hasHandledBubbleRuntime = false;
    _hasHandledServerBubble = false;
    final notifier = ref.read(homeSummaryProvider.notifier);
    if (showCardLoading) {
      await notifier.refreshWithLoading();
    } else {
      await notifier.refresh();
    }
  }

  Future<void> _refreshHomeData() => _refreshOnEntry();

  void _attachRouteListenerIfNeeded() {
    if (_routeListenerAttached) return;

    final router = GoRouter.maybeOf(context);
    if (router == null) return;

    _routeListenerAttached = true;
    _lastKnownRoutePath = router.routeInformationProvider.value.uri.path;

    _routeListener = () {
      if (!mounted) return;

      final path = router.routeInformationProvider.value.uri.path;
      final isHome = path == '/home';
      final wasHome = _lastKnownRoutePath == '/home';
      _lastKnownRoutePath = path;

      if (isHome && !wasHome) {
        unawaited(_refreshOnEntry());
      }
    };
    router.routeInformationProvider.addListener(_routeListener!);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentVideoBaseName = 'nugul_home';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(homeSummaryProvider).hasValue) {
        unawaited(_refreshOnEntry());
      }
      _syncVideoPlayback(
        defaultVideoBaseName: 'nugul_home',
        hasSpecial: false,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachRouteListenerIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _videoController == null) {
      return;
    }
  }

  void _hideBalloon() {
    _balloonDismissTimer?.cancel();
    _balloonDismissTimer = null;
    if (!mounted) return;
    setState(() {
      _visibleBalloonMessage = null;
      _visibleBubbleType = null;
    });
  }

  Future<void> _showBalloon(String message, HomeBubbleType type) async {
    if (_visibleBalloonMessage != null && _visibleBubbleType == type) {
      return;
    }

    _balloonDismissTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _visibleBalloonMessage = message;
      _visibleBubbleType = type;
    });

    _balloonDismissTimer = Timer(_balloonDuration, () {
      if (!mounted) return;
      _hideBalloon();
    });
  }

  Future<void> _presentServerBubble(HomeBubbleSummary bubble) async {
    if (!mounted ||
        _hasHandledServerBubble ||
        _isShowingBubble ||
        _visibleBalloonMessage != null) {
      return;
    }

    _hasHandledServerBubble = true;
    _hasHandledBubbleRuntime = true;
    _isShowingBubble = true;
    try {
      final type = bubble.toHomeBubbleType();
      final selection =
          ref.read(homeBubbleSelectorProvider).selectForResultBubble(type);
      if (selection == null) return;
      await _showBalloon(selection.message, selection.type);
      await ref.read(homeSummaryProvider.notifier).acknowledgeHomeBubbleSeen();
    } catch (error, stackTrace) {
      debugPrint('home server bubble failed: $error\n$stackTrace');
    } finally {
      _isShowingBubble = false;
    }
  }

  Future<void> _tryPresentPendingConsiderBubble() async {
    if (!mounted ||
        _hasHandledBubbleRuntime ||
        _hasHandledServerBubble ||
        _isShowingBubble ||
        _visibleBalloonMessage != null) {
      return;
    }

    final localStore = await ref.read(homeBubbleLocalStoreProvider.future);
    final pendingType = await localStore.peekPendingResultBubble();
    if (pendingType == null) return;

    final selection =
        ref.read(homeBubbleSelectorProvider).selectForResultBubble(pendingType);
    if (selection == null) return;

    _hasHandledBubbleRuntime = true;
    _isShowingBubble = true;
    try {
      await _showBalloon(selection.message, selection.type);
      await localStore.consumePendingResultBubble();
      try {
        await ref
            .read(homeSummaryServiceProvider)
            .markBubbleSeenByType(type: 'DECISION_REACTION');
      } catch (error, stackTrace) {
        debugPrint('decision reaction seen api failed: $error\n$stackTrace');
      }
    } catch (error, stackTrace) {
      debugPrint('pending consider bubble failed: $error\n$stackTrace');
    } finally {
      _isShowingBubble = false;
    }
  }

  @override
  void dispose() {
    final router = GoRouter.maybeOf(context);
    if (router != null && _routeListener != null) {
      router.routeInformationProvider.removeListener(_routeListener!);
    }

    WidgetsBinding.instance.removeObserver(this);
    _balloonDismissTimer?.cancel();
    _detachSpecialListener(_videoController);
    _pendingSpecialDispose?.dispose();
    _pendingSpecialDispose = null;
    _parkedDefaultController?.dispose();
    _parkedDefaultController = null;

    final controller = _videoController;
    if (controller != null) {
      ref.read(homeSpecialEffectProvider.notifier).detachController(controller);
      controller.dispose();
      _videoController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final summary = ref.watch(homeSummaryProvider).valueOrNull;
    final authUser = ref.watch(authProvider).valueOrNull;

    ref.listen<AsyncValue<HomeSummaryResponse?>>(
      homeSummaryProvider,
      (previous, next) {
        if (authUser == null) return;
        next.whenData((loadedSummary) {
          if (loadedSummary == null) return;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final specialState = ref.read(homeSpecialEffectProvider);
            _syncVideoPlayback(
              defaultVideoBaseName: loadedSummary.defaultVideoBaseName,
              hasSpecial: specialState.hasPendingSpecial,
            );
          });

          final bubble = loadedSummary.bubble;
          if (bubble != null && bubble.shouldShow) {
            unawaited(_presentServerBubble(bubble));
            return;
          }
          unawaited(_tryPresentPendingConsiderBubble());
        });
      },
    );

    ref.listen<HomeSpecialEffectState>(homeSpecialEffectProvider,
        (previous, next) {
      if (!next.hasPendingSpecial) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final latestSummary = ref.read(homeSummaryProvider).valueOrNull;
        _syncVideoPlayback(
          defaultVideoBaseName:
              latestSummary?.defaultVideoBaseName ?? 'nugul_home',
          hasSpecial: true,
        );
      });
    });

    final activeController = _videoController;
    final mascotBaseName = _isPlayingSpecialOnce
        ? videoBaseNameFromDataSource(activeController?.dataSource ?? '')
        : _currentVideoBaseName;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _onNugulTap,
            behavior: HitTestBehavior.opaque,
            child: activeController != null &&
                    activeController.value.isInitialized &&
                    !activeController.value.hasError
                ? HomeMascotVideo(
                    key: const ValueKey('home_mascot'),
                    controller: activeController,
                    videoBaseName: mascotBaseName,
                  )
                : const ColoredBox(color: Color(0xFFD9E9F2)),
          ),
          RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        MainTabHeader(
                          leading: SvgPicture.asset(
                            'assets/images/wigul_logo.svg',
                            height: 32 * scale,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          badgeCount: summary?.notifications.unreadCount,
                          onAlarmPressed: () =>
                              openNotificationsPage(ref, context),
                        ),
                        SizedBox(height: 20 * scale),
                        Expanded(
                          child: GestureDetector(
                            onTap: _onNugulTap,
                            child: Column(
                              children: [
                                if (_visibleBalloonMessage != null) ...[
                                  Flexible(
                                    child: SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 24 * scale,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 37 * scale,
                                              vertical: 19 * scale,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha:
                                                    _balloonBackgroundOpacity,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      40 * scale),
                                            ),
                                            child: Text(
                                              _visibleBalloonMessage!,
                                              textAlign: TextAlign.center,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontSize: 18 * scale,
                                                height: 24 / 20,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF555555),
                                              ),
                                            ),
                                          ),
                                          CustomPaint(
                                            size: Size(20 * scale, 10 * scale),
                                            painter: TrianglePainter(
                                              opacity:
                                                  _balloonBackgroundOpacity,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else
                                  SizedBox(height: 10 * scale),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                        HomeInfoCarousel(
                          onBudgetTap: () async {
                            final updated =
                                await context.push<bool>('/my/consumption');
                            if (!mounted) return;
                            if (updated != true) return;
                            await _refreshOnEntry(showCardLoading: true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class TrianglePainter extends CustomPainter {
  const TrianglePainter({this.opacity = 0.7});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
