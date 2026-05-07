import 'dart:math';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/home/views/components/budget_card.dart';
import 'package:fe_app/features/home/views/components/home_info_container.dart';
import 'package:fe_app/features/home/views/components/selection_rate_card.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:fe_app/shared/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  bool _isBudgetExceeded = false;

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

  // 너구리나 배경 클릭 시 실행될 함수
  void _onNugulTap() {
    // 1. 메시지 랜덤 변경
    _changeMessage();

    // 2. 영상 처음부터 다시 재생
    if (_videoController.value.isInitialized) {
      _videoController.seekTo(Duration.zero);
      _videoController.play();
    }
  }

  void _changeMessage() {
    final random = Random();
    final messageList = _isBudgetExceeded ? _warningMessages : _safeMessages;
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
    return Scaffold(
      body: Stack(
        children: [
          // 1. 배경 영상 레이어 + 클릭 감지
          GestureDetector(
            onTap: _onNugulTap, // 화면 배경(너구리) 클릭 시 작동
            behavior: HitTestBehavior.opaque, // 빈 공간 클릭도 감지
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

          // 2. UI 레이어 (영상 위에 배치)
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: SvgPicture.asset(
                          'assets/images/wigul_logo.svg',
                          height: 32,
                          colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0), // 패딩을 약간 조정
                        child: AlarmButton(
                          onPressed: () => context.push('/notifications'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 말풍선 영역 (클릭 가능)
                GestureDetector(
                  onTap: _onNugulTap,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Text(
                          _currentMessage,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(),
                      ),
                    ],
                  ),
                ),

                // 중간 공간 (여기 덕분에 너구리가 보임)
                const Spacer(),

                // 하단 카드 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                  child: HomeInfoContainer(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: 160,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            children: const [
                              BudgetCard(),
                              SelectionRateCard(),
                            ],
                          ),
                        ),
                        // 인디케이터
                        Positioned(
                          top: -12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: index == _currentPage ? 18 : 8,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: index == _currentPage ? AppColors.skyBlue : const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(2),
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
    var paint = Paint()..color = Colors.white.withOpacity(0.85);
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
