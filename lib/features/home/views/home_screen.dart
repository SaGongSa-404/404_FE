import 'dart:math';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_info_container.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/features/profile/providers/profile_provider.dart';
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
  late VideoPlayerController _videoController;
  int _currentPage = 0;

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

  @override
  void initState() {
    super.initState();
    _currentMessage = _safeMessages[0];

    _videoController = VideoPlayerController.asset('assets/videos/nugul_home.mp4')
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
      });
  }

  void _onNugulTap(bool isExceeded) {
    _changeMessage(isExceeded);
    if (_videoController.value.isInitialized) {
      _videoController.seekTo(Duration.zero);
      _videoController.play();
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
  void dispose() {
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final profile = ref.watch(profileNotifierProvider);
    final isExceeded = profile.currentMonthRecord.isExceeded;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => _onNugulTap(isExceeded),
            behavior: HitTestBehavior.opaque,
            child: _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
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
                    colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                  ),
                  onAlarmPressed: () => context.push('/notifications'),
                ),
                SizedBox(height: 20 * scale),
                GestureDetector(
                  onTap: () => _onNugulTap(isExceeded),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40 * scale, vertical: 16 * scale),
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
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 40 * scale),
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
                                  color: index == _currentPage ? AppColors.skyBlue_100 : const Color(0xFFE0E0E0),
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
    var paint = Paint()..color = Colors.white.withAlpha(217);
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
