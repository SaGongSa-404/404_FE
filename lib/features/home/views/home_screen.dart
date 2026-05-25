import 'dart:async';
import 'dart:math';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_special_effect_provider.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_info_container.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  VideoPlayerController? _videoController;
  int _currentPage = 0;
  String _currentVideoPath = '';
  bool _isPlayingSpecialOnce = false;
  bool _isInitializing = false;
  VoidCallback? _specialListener;

  final List<String> _safeMessages = [
    '잘하고 있어요! 예산이 넉넉해요 :)',
    '이대로만 소비하면 이번 달은 성공이에요!',
    '당신은 정말 현명한 소비왕!',
    '너구리도 당신의 절약 정신에 감동했어요!',
  ];

  final List<String> _warningMessages = [
    '앗! 예산이 얼마 남지 않았어요. 주의하세요!',
    '지갑이 울고 있어요... 조금만 참아볼까요?',
    '경고! 충동구매의 기운이 느껴집니다!',
  ];

  late String _currentMessage;

  String _getDefaultVideoPath(bool isBudgetExhausted) {
    return isBudgetExhausted
        ? 'assets/videos/nugul_embarrassed.mp4'
        : 'assets/videos/nugul_home.mp4';
  }

  String _getSpecialVideoPath(ConsiderCaseType caseType) {
    switch (caseType) {
      case ConsiderCaseType.caseA:
      case ConsiderCaseType.caseC:
        return 'assets/videos/nugul_sunny_smile.mp4';
      case ConsiderCaseType.caseB:
        return 'assets/videos/nugul_rainy.mp4';
      case ConsiderCaseType.caseD:
        return 'assets/videos/nugul_sunny_happy.mp4';
    }
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

    void onTick() async {
      if (!mounted || _videoController != preloadedController) {
        preloadedController.removeListener(onTick);
        return;
      }
      
      final value = preloadedController.value;
      if (!value.isInitialized) return;

      final isAtEnd = value.position >= value.duration && value.duration > Duration.zero;
      if (isAtEnd && !value.isPlaying) {
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

  void _onNugulTap(bool isExceeded) {
    _changeMessage(isExceeded);
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  void _changeMessage(bool isExceeded) {
    final random = Random();
    final messageList = isExceeded ? _warningMessages : _safeMessages;
    setState(() {
      _currentMessage = messageList[random.nextInt(messageList.length)];
    });
  }

  @override
  void initState() {
    super.initState();
    _currentMessage = _safeMessages[0];
    
    final profile = ref.read(profileNotifierProvider);
    final currentRecord = profile.currentMonthRecord;
    final isBudgetExhausted = (currentRecord.budget - currentRecord.spentAmount) <= 0;
    _currentVideoPath = _getDefaultVideoPath(isBudgetExhausted);
  }

  @override
  void dispose() {
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
    final profile = ref.watch(profileNotifierProvider);
    final currentRecord = profile.currentMonthRecord;
    final isExceeded = currentRecord.isExceeded;

    final remainingBudget = currentRecord.budget - currentRecord.spentAmount;
    final isBudgetExhausted = remainingBudget <= 0;
    final defaultVideoPath = _getDefaultVideoPath(isBudgetExhausted);

    final specialState = ref.watch(homeSpecialEffectProvider);
    final preloadedController = specialState.preloadedController;
    final hasSpecial = specialState.caseType != null && preloadedController != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (hasSpecial && !_isPlayingSpecialOnce) {
        _playPreloadedSpecialAndRestore(
          preloadedController: preloadedController!,
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
            onTap: () => _onNugulTap(isExceeded),
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
                  onAlarmPressed: () => context.push('/notifications'),
                ),
                SizedBox(height: 20 * scale),
                GestureDetector(
                  onTap: () => _onNugulTap(isExceeded),
                  child: Column(
                    children: [
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
                          _currentMessage,
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
