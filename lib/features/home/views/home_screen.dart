import 'dart:async';
import 'dart:math';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/models/balloon_message.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/home/services/home_balloon_service.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_info_container.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:fe_app/features/wishlist/viewmodels/wishlist_viewmodel.dart';
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
  bool _isPlayingSpecialOnce = false;
  bool _isInitializing = false;
  bool _hasUserInteractedWithMascot = false;
  VoidCallback? _specialListener;
  Timer? _balloonDismissTimer;
  String? _visibleBalloonMessage;
  BalloonMessageType? _visibleBalloonType;
  ConsiderCaseType? _lastSpecialCaseType;
  bool _requestLaunchBalloonEvaluation = false;

  String _getDefaultVideoPath(bool isBudgetExhausted) {
    return isBudgetExhausted
        ? 'assets/videos/nugul_embarrassed.mp4'
        : 'assets/videos/nugul_home.mp4';
  }

  Future<void> _initializeVideo(String videoPath, {bool loop = true}) async {
    if (_isInitializing) return;
    
    if (_currentVideoPath == videoPath && 
        _videoController != null && 
        _videoController!.value.isInitialized &&
        !_isPlayingSpecialOnce) {
      return;
    }

    _isInitializing = true;
    final controller = VideoPlayerController.asset(videoPath);
    try {
      await controller.setVolume(0);
      await controller.initialize();
      controller.setLooping(loop);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _cleanupOldController();

      setState(() {
        _videoController = controller;
        _currentVideoPath = videoPath;
      });

      await controller.play();
    } catch (e) {
      debugPrint('Video initialization error: $e');
      await controller.dispose();
    } finally {
      _isInitializing = false;
    }
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
    required String defaultVideoPath,
  }) async {
    if (_isPlayingSpecialOnce) return;
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

        await _initializeVideo(defaultVideoPath, loop: true);
        _isPlayingSpecialOnce = false;
      }
    }

    _specialListener = onTick;
    preloadedController.addListener(onTick);
  }

  void _onNugulTap() {
    _hasUserInteractedWithMascot = true;
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentVideoPath = 'assets/videos/nugul_home.mp4';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(wishlistViewModelProvider.notifier).reloadOnScreenOpen());
      _requestLaunchBalloonEvaluation = true;
      unawaited(_processBalloonQueue());
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
      _visibleBalloonType = null;
    });
  }

  Future<void> _showBalloon(String message, BalloonMessageType type) async {
    if (_visibleBalloonMessage != null && _visibleBalloonType == type) {
      return;
    }

    _balloonDismissTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _visibleBalloonMessage = message;
      _visibleBalloonType = type;
    });

    _balloonDismissTimer = Timer(_balloonDuration, () {
      if (!mounted) return;
      _hideBalloon();
    });
  }

  Future<void> _showBalloonForType(BalloonMessageType type) async {
    final message = HomeBalloonService.pickRandomText(type);
    if (message == null) return;
    await _showBalloon(message, type);
  }

  Future<void> _processBalloonQueue() async {
    if (!mounted || _visibleBalloonMessage != null) return;

    final specialState = ref.read(homeSpecialEffectProvider);
    final specialCaseType = specialState.caseType;
    if (specialCaseType != null && specialCaseType != _lastSpecialCaseType) {
      _lastSpecialCaseType = specialCaseType;
      HomeBalloonService.markLaunchEvaluatedThisSession();
      final balloonType = HomeBalloonService.balloonTypeForDecisionCase(specialCaseType);
      if (balloonType != null) {
        await _showBalloonForType(balloonType);
      }
      return;
    }

    if (await HomeBalloonService.consumePendingOnboarding()) {
      HomeBalloonService.markLaunchEvaluatedThisSession();
      await _showBalloonForType(BalloonMessageType.onboarding);
      return;
    }

    if (await HomeBalloonService.consumePendingFirstWish()) {
      HomeBalloonService.markLaunchEvaluatedThisSession();
      await _showBalloonForType(BalloonMessageType.firstWishAdded);
      return;
    }

    if (HomeBalloonService.launchEvaluatedThisSession || !_requestLaunchBalloonEvaluation) {
      return;
    }

    final summary = ref.read(homeSummaryProvider).valueOrNull;
    final authUser = ref.read(authProvider).valueOrNull;
    final wishlistState = ref.read(wishlistViewModelProvider);
    if (summary == null || authUser == null || wishlistState.isLoading) return;

    HomeBalloonService.markLaunchEvaluatedThisSession();

    final budget = summary.budget;
    if (budget.remainingAmount < 0) {
      await _showBalloonForType(BalloonMessageType.budgetNegative);
      return;
    }

    if (budget.remainingAmount == 0) {
      await _showBalloonForType(BalloonMessageType.budgetExhausted);
      return;
    }

    final wishCount = wishlistState.items.length;
    final hasWishlistData = wishlistState.listErrorMessage == null;
    final hasPostsAwaitingVote = summary.notifications.latestNotifications.any(
      (item) => (item.type ?? '').toUpperCase() == 'SOCIAL_VOTE',
    );

    if (hasWishlistData && wishCount == 0) {
      await _showBalloonForType(BalloonMessageType.emptyWishlist);
      return;
    }

    if (!hasWishlistData) {
      await _showBalloonForType(BalloonMessageType.normalHome);
      return;
    }

    final random = Random();
    if (random.nextDouble() < 0.7) {
      await _showBalloonForType(BalloonMessageType.undecidedWish);
      return;
    }

    if (hasPostsAwaitingVote) {
      await _showBalloonForType(BalloonMessageType.awaitingVote);
      return;
    }

    await _showBalloonForType(BalloonMessageType.normalHome);
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
    final wishlistState = ref.watch(wishlistViewModelProvider);

    final isBudgetExhausted = summary?.budget.isBudgetExhausted ?? false;
    final defaultVideoPath = _getDefaultVideoPath(isBudgetExhausted);

    final specialState = ref.watch(homeSpecialEffectProvider);
    final preloadedController = specialState.preloadedController;
    final hasSpecial = specialState.caseType != null && preloadedController != null;

    ref.listen<HomeSpecialEffectState>(homeSpecialEffectProvider, (previous, next) {
      if (next.caseType == null) {
        _lastSpecialCaseType = null;
        return;
      }
      if (previous?.caseType != next.caseType) {
        _lastSpecialCaseType = next.caseType;
        HomeBalloonService.markLaunchEvaluatedThisSession();
        unawaited(HomeBalloonService.consumePendingDecisionCase());
        final balloonType = HomeBalloonService.balloonTypeForDecisionCase(next.caseType!);
        if (balloonType != null) {
          unawaited(_showBalloonForType(balloonType));
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_requestLaunchBalloonEvaluation) {
        _requestLaunchBalloonEvaluation = true;
      }
      unawaited(_processBalloonQueue());

      if (hasSpecial && !_isPlayingSpecialOnce) {
        if (preloadedController == null) return;
        _playPreloadedSpecialAndRestore(
          preloadedController: preloadedController,
          defaultVideoPath: defaultVideoPath,
        );
        return;
      }

      if (!_isPlayingSpecialOnce && !_isInitializing && _currentVideoPath != defaultVideoPath) {
        _initializeVideo(defaultVideoPath, loop: true);
      } else if (_videoController == null && !_isInitializing) {
        _initializeVideo(defaultVideoPath, loop: true);
      }
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
          SafeArea(
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
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            children: const [
                              BudgetCard(),
                              SelectionRateCard(),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -12 * scale,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 3 * scale),
                                width: (index == _currentPage ? 18 : 8) * scale,
                                height: 4 * scale,
                                decoration: BoxDecoration(
                                  color: index == _currentPage
                                      ? AppColors.skyBlue_100
                                      : const Color(0xFFE0E0E0),
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
