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
  bool _isSchedulingSpecialPlayback = false;
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
    }
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
    if (_isPlayingSpecialOnce || _isInitializing) return;

    final preloadedController = ref
        .read(homeSpecialEffectProvider.notifier)
        .takePreloadedController();
    if (preloadedController == null) return;

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

      alreadyFinished = true;
      preloadedController.removeListener(onTick);
      _specialListener = null;
      unawaited(_restoreDefaultVideo(defaultVideoBaseName));
    }

    _specialListener = onTick;
    preloadedController.addListener(onTick);
  }

  void _scheduleDefaultVideoIfNeeded(String defaultVideoBaseName) {
    if (_isPlayingSpecialOnce ||
        _isInitializing ||
        _isSchedulingSpecialPlayback ||
        ref.read(homeSpecialEffectProvider).hasPendingSpecial) {
      return;
    }

    final needsDefaultVideo = _videoController == null ||
        !_videoController!.value.isInitialized ||
        _videoController!.value.hasError ||
        _currentVideoBaseName != defaultVideoBaseName;

    if (!needsDefaultVideo) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isPlayingSpecialOnce || _isInitializing) return;
      unawaited(_initializeVideo(defaultVideoBaseName, loop: true));
    });
  }

  void _scheduleSpecialPlaybackIfNeeded(String defaultVideoBaseName) {
    if (_isPlayingSpecialOnce ||
        _isSchedulingSpecialPlayback ||
        _isInitializing) {
      return;
    }

    final specialState = ref.read(homeSpecialEffectProvider);
    if (!specialState.hasPendingSpecial) return;

    _isSchedulingSpecialPlayback = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isSchedulingSpecialPlayback = false;
      if (!mounted || _isPlayingSpecialOnce) return;
      unawaited(
        _playPreloadedSpecialAndRestore(
          defaultVideoBaseName: defaultVideoBaseName,
        ),
      );
    });
  }

  void _onNugulTap() {
    _hasUserInteractedWithMascot = true;
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  Future<void> _refreshHomeData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _hasHandledBubbleRuntime = false;
    ref.read(homeBubbleRefreshProvider)();

    try {
      await Future.wait([
        ref.read(homeSummaryProvider.notifier).refresh(),
        ref.read(consumptionStatsProvider.notifier).load(force: true),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentVideoBaseName = 'nugul_home';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refreshHomeData());
    });
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

  Future<void> _presentBubbleEvaluation(HomeBubbleEvaluation evaluation) async {
    if (!mounted || _isShowingBubble || _visibleBalloonMessage != null) {
      return;
    }

    _isShowingBubble = true;
    try {
      await _showBalloon(
        evaluation.selection.message,
        evaluation.selection.type,
      );
      final engine = await ref.read(homeBubbleEngineProvider.future);
      await engine.commitAfterDisplayed(evaluation.commit);
    } catch (error, stackTrace) {
      debugPrint('home bubble presentation failed: $error\n$stackTrace');
    } finally {
      _isShowingBubble = false;
    }
  }

  Future<void> _onBubbleRuntimeReady(HomeBubbleRuntimeState runtime) async {
    if (!mounted || _hasHandledBubbleRuntime) return;
    _hasHandledBubbleRuntime = true;

    final evaluation = runtime.evaluation;
    if (evaluation == null) return;

    await _presentBubbleEvaluation(evaluation);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _balloonDismissTimer?.cancel();
    _pageController.dispose();
    final controller = _videoController;
    if (controller != null) {
      if (_specialListener != null) {
        controller.removeListener(_specialListener!);
        _specialListener = null;
      }
      ref.read(homeSpecialEffectProvider.notifier).detachController(controller);
      controller.dispose();
      _videoController = null;
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final summaryAsync = ref.watch(homeSummaryProvider);
    final summary = summaryAsync.valueOrNull;
    final authUser = ref.watch(authProvider).valueOrNull;

    final statsState = ref.watch(consumptionStatsProvider);
    final currentRecord = statsState.currentMonthStats;

    final remainingBudget = currentRecord == null
        ? 1
        : currentRecord.budgetAmount - currentRecord.spentAmount;
    final isBudgetExhausted = currentRecord != null && remainingBudget <= 0;
    final defaultVideoBaseName = _getDefaultVideoBaseName(isBudgetExhausted);

    ref.listen<HomeSpecialEffectState>(homeSpecialEffectProvider, (previous, next) {
      if (next.hasPendingSpecial) {
        _scheduleSpecialPlaybackIfNeeded(defaultVideoBaseName);
      }
    });

    if (authUser != null) {
      ref.watch(homeBubbleRuntimeProvider);
      ref.listen<AsyncValue<HomeBubbleRuntimeState>>(
        homeBubbleRuntimeProvider,
        (previous, next) {
          next.when(
            data: (runtime) => unawaited(_onBubbleRuntimeReady(runtime)),
            error: (_, __) => _hasHandledBubbleRuntime = true,
            loading: () {},
          );
        },
      );
    }

    _scheduleSpecialPlaybackIfNeeded(defaultVideoBaseName);
    _scheduleDefaultVideoIfNeeded(defaultVideoBaseName);

    final videoController = _videoController;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _onNugulTap,
            behavior: HitTestBehavior.opaque,
            child: videoController != null && videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: videoController.value.size.width,
                        height: videoController.value.size.height,
                        child: VideoPlayer(
                          videoController,
                          key: ValueKey('${videoController.hashCode}_$_currentVideoPath'),
                        ),
                      ),
                    ),
                  )
                : Container(color: const Color(0xFFD9E9F2)),
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
                          onAlarmPressed: () => context.push('/notifications'),
                        ),
                        SizedBox(height: 20 * scale),
                        GestureDetector(
                          onTap: _onNugulTap,
                          child: Column(
                            children: [
                              if (_visibleBalloonMessage != null) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40 * scale,
                                    vertical: 16 * scale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(217),
                                    borderRadius: BorderRadius.circular(40 * scale),
                                  ),
                                  child: Text(
                                    _visibleBalloonMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                CustomPaint(
                                  size: Size(20 * scale, 10 * scale),
                                  painter: TrianglePainter(),
                                ),
                              ] else
                                SizedBox(height: 10 * scale),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * scale,
                            vertical: 40 * scale,
                          ),
                          child: HomeInfoContainer(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 160 * scale,
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (index) =>
                                        setState(() => _currentPage = index),
                                    children: [
                                      BudgetCard(
                                        onTap: () async {
                                          final updated =
                                              await context.push<bool>('/my/consumption');
                                          if (!mounted) return;
                                          if (updated == true) {
                                            unawaited(_refreshHomeData());
                                          }
                                        },
                                      ),
                                      const SelectionRateCard(),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: -12 * scale,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: List.generate(2, (index) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 3 * scale,
                                        ),
                                        width:
                                            (index == _currentPage ? 18 : 8) * scale,
                                        height: 4 * scale,
                                        decoration: BoxDecoration(
                                          color: index == _currentPage
                                              ? const Color(0xFFCACACA)
                                              : const Color(0xFFE5E5E5),
                                          borderRadius: BorderRadius.circular(2 * scale),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRefreshing)
            const Positioned.fill(child: NugulLoadingScreen()),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(217);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
