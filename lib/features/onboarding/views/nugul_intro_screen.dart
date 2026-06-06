import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_progress_indicator.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class NugulIntroScreen extends ConsumerStatefulWidget {
  const NugulIntroScreen({super.key});

  @override
  ConsumerState<NugulIntroScreen> createState() => _NugulIntroScreenState();
}

class _NugulIntroScreenState extends ConsumerState<NugulIntroScreen> {
  static const _designW = 412.0;

  Future<void> _onNext() async {
    final success =
        await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final msg = ref.read(onboardingProvider).errorMessage ??
          '온보딩 완료 중 오류가 발생했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final mascotName = state.mascotName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final scale = w / _designW;
            final hPad = (w * 24 / _designW).clamp(20.0, 48.0);
            final innerW = w - hPad * 2;
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
                            const Spacer(flex: 65),
                            OnboardingProgressIndicator(
                              currentStep: 4,
                              totalSteps: 4,
                              onBack: () {
                                if (context.canPop()) context.pop();
                              },
                            ),
                            const Spacer(flex: 97),
                            Text(
                              '위시템을 담으면\n솜사탕이 생겨요.',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: (26 * scale).clamp(19.0, 33.0),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.36,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '맑은 날엔 너굴이가 솜사탕을 맛있게\n먹을 수 있어요!',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: (18 * scale).clamp(14.0, 23.0),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.45,
                              ),
                            ),
                            const Spacer(flex: 87),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _SpeechBubble(
                                    nickname:
                                        mascotName.isEmpty ? '친구' : mascotName,
                                    width: charW,
                                    scale: scale,
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
                            const Spacer(flex: 12),
                            OnboardingPrimaryButton(
                              label: '시작하기',
                              onPressed: state.isLoading ? null : _onNext,
                              fontSize: (18 * scale).clamp(14.0, 23.0),
                            ),
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
  const _SpeechBubble({
    required this.nickname,
    required this.width,
    required this.scale,
  });

  final String nickname;
  final double width;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: const _BubblePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Text(
            '안녕하세요, $nickname님!\n저는 너굴이에요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: (16 * scale).clamp(12.0, 21.0),
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
