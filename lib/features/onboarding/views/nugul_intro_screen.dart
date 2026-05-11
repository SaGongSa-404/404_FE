import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class NugulIntroScreen extends ConsumerWidget {
  const NugulIntroScreen({
    super.key,
    this.currentStep = 6,
    this.totalSteps = 6,
  });

  final int currentStep;
  final int totalSteps;

  // 피그마 기준 프레임 너비 (Android Compact 390px)
  static const _designW = 390.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(onboardingProvider).nickname;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // 수평 패딩: 24/390 비율, 20~48px clamp
            final hPad = (w * 24 / _designW).clamp(20.0, 48.0);
            final innerW = w - hPad * 2;
            // 캐릭터 너비: 피그마 208/342(innerW) ≈ 61%, 140~210px clamp
            final charW = (innerW * 0.61).clamp(140.0, 210.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 상단 여백: 피그마 65/844 비율
                            const Spacer(flex: 65),

                            OnboardingProgressIndicator(
                              currentStep: currentStep,
                              totalSteps: totalSteps,
                              onBack: () {
                                if (context.canPop()) context.pop();
                              },
                            ),

                            // 인디케이터 ↔ 텍스트: gap 23 + 텍스트 상단 패딩 74 = 97/844 비율
                            const Spacer(flex: 97),

                            const Text(
                              '위시템을 담으면\n솜사탕이 생겨요.',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.36,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              '맑은 날엔 너굴이가 솜사탕을 맛있게\n먹을 수 있어요!',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.45,
                              ),
                            ),

                            // 텍스트↔캐릭터 여백: 87/844 비율
                            const Spacer(flex: 87),

                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _SpeechBubble(
                                    nickname:
                                        nickname.isEmpty ? '친구' : nickname,
                                    width: charW,
                                  ),
                                  const SizedBox(height: 11),
                                  Image.asset(
                                    'assets/images/nugul_candy.png',
                                    width: charW,
                                    height: charW,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),

                            // 캐릭터 ↔ 버튼 여백: 12/844 비율
                            const Spacer(flex: 12),

                            OnboardingPrimaryButton(
                              label: '다음',
                              onPressed: () => context.go('/home'),
                            ),

                            // 하단 여백: 40/844 비율
                            const Spacer(flex: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.nickname, required this.width});

  final String nickname;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: const _BubblePainter(),
        child: Padding(
          // 좌우 24px + 상 16px + 하 30px (내용 패딩 16 + 꼬리 공간 14)
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Text(
            '안녕하세요, $nickname님!\n저는 너굴이에요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  static const _r = 22.0;
  static const _tailH = 14.0;
  static const _tailHW = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    const r = _r;
    const th = _tailH;
    const thw = _tailHW;
    final bb = size.height - th;
    final tx = size.width / 2;

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, bb - r)
      ..arcToPoint(Offset(size.width - r, bb), radius: const Radius.circular(r))
      ..lineTo(tx + thw, bb)
      ..lineTo(tx, size.height)
      ..lineTo(tx - thw, bb)
      ..lineTo(r, bb)
      ..arcToPoint(Offset(0, bb - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    // 피그마 drop-shadow(0 0 3px rgba(0,0,0,0.2)) 재현
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
