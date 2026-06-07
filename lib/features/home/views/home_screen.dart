import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/core/utils/video_asset.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/home/domain/home_bubble_type.dart';
import 'package:fe_app/features/home/providers/home_bubble_provider.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/notification/utils/notification_navigation.dart';
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
    this.preloadedController,
  });

  final String defaultVideoBaseName;
  final bool hasSpecial;
  final VideoPlayerController? preloadedController;
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
    required VideoPlayerController? preloadedController,
  }) {
    _pendingSyncRequest = _PendingVideoSyncRequest(
      defaultVideoBaseName: defaultVideoBaseName,
      hasSpecial: hasSpecial,
      preloadedController: preloadedController,
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

    if (!mounted) return;

    await preloadedController.setLooping(false);
    await preloadedController.seekTo(Duration.zero);

    setState(() {
      _videoController = preloadedController;
      _currentVideoPath = preloadedController.dataSource;
    });

    await preloadedController.play();

    if (oldController != null) {
      Future.delayed(const Duration(milliseconds: 200), () => oldController.dispose());
    }

    // 영상의 개수를 비교하여 한 번만 재생되도록 처리
    bool alreadyReturned = false;
    
    void onTick() async {
      if (alreadyReturned || !mounted || _videoController != preloadedController) {
        preloadedController.removeListener(onTick);
        return;
      }
      
      final value = preloadedController.value;
      if (!value.isInitialized || value.duration <= Duration.zero) return;

      // 정확한 종료 감지: position이 duration과 거의 같을 때
      // (duration - 100ms 이내)
      final remainingMs = value.duration.inMilliseconds - value.position.inMilliseconds;
      
      if (remainingMs <= 100 && !value.isPlaying) {
        alreadyReturned = true;
        preloadedController.removeListener(onTick);
        _specialListener = null;

        ref.read(homeSpecialEffectProvider.notifier).resetAfterPlay();

        if (!mounted) return;

        await _initializeVideo(defaultVideoBaseName, loop: true);
        _isPlayingSpecialOnce = false;
        _tryDrainPendingSyncRequest();
      }
    }

    _specialListener = onTick;
    preloadedController.addListener(onTick);
  }

  void _onNugulTap() {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  void _syncVideoPlayback({
    required String defaultVideoBaseName,
    required bool hasSpecial,
    required VideoPlayerController? preloadedController,
  }) {
    if (!mounted) return;

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
      _syncVideoPlayback(
        defaultVideoBaseName: 'nugul_home',
        hasSpecial: false,
        preloadedController: null,
      );
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
    if (_videoController != null && _specialListener != null) {
      _videoController!.removeListener(_specialListener!);
    }
    _videoController?.dispose();
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

    ref.listen(homeSpecialEffectProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncVideoPlayback(
          defaultVideoBaseName: defaultVideoBaseName,
          hasSpecial: next.caseType != null && next.preloadedController != null,
          preloadedController: next.preloadedController,
        );
      });
    });

    ref.listen(consumptionStatsProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final record = next.currentMonthStats;
        final remaining = record == null
            ? 1
            : record.budgetAmount - record.spentAmount;
        final isExhausted = record != null && remaining <= 0;
        final specialState = ref.read(homeSpecialEffectProvider);
        _syncVideoPlayback(
          defaultVideoBaseName: _getDefaultVideoBaseName(isExhausted),
          hasSpecial: specialState.caseType != null &&
              specialState.preloadedController != null,
          preloadedController: specialState.preloadedController,
        );
      });
    });

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
                          onAlarmPressed: () => openNotificationsPage(ref, context),
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
                                      physics: const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 40 * scale,
                                              vertical: 16 * scale,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(217),
                                              borderRadius:
                                                  BorderRadius.circular(40 * scale),
                                            ),
                                            child: Text(
                                              _visibleBalloonMessage!,
                                              textAlign: TextAlign.center,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
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
