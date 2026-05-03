import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:fe_app/features/onboarding/views/components/nugul_video.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_primary_button.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class NugulIntroScreen extends ConsumerWidget {
  const NugulIntroScreen({super.key});

  static const _designWidth = 412.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(onboardingProvider).nickname;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                (constraints.maxWidth * (36 / _designWidth)).clamp(24.0, 60.0);
            final innerWidth = constraints.maxWidth - (horizontalPadding * 2);
            final nugulSize = (innerWidth * 0.45).clamp(130.0, 185.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 50),
                            _CharacterSection(
                              nickname: nickname.isEmpty ? '친구' : nickname,
                              nugulSize: nugulSize,
                            ),
                            const Spacer(flex: 130),
                            const _DescriptionText(),
                            const SizedBox(height: 32),
                            OnboardingPrimaryButton(
                              label: '너굴 만나러 가기',
                              onPressed: () => context.go('/home'),
                            ),
                            const Spacer(flex: 80),
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

class _CharacterSection extends StatelessWidget {
  const _CharacterSection({
    required this.nickname,
    required this.nugulSize,
  });

  final String nickname;
  final double nugulSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SpeechBubble(
          nickname: nickname,
          tailCenterX: nugulSize / 2,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: NugulVideo(size: nugulSize),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.nickname,
    required this.tailCenterX,
  });

  final String nickname;
  final double tailCenterX;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(tailCenterX: tailCenterX),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 42),
        child: Text(
          '안녕하세요, $nickname님!\n저는 너굴이에요.',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
            height: 1.55,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  _SpeechBubblePainter({required this.tailCenterX});

  final double tailCenterX;

  static const _radius = 20.0;
  static const _tailHeight = 20.0;
  static const _tailHalfWidth = 14.0;
  static const _borderColor = Color(0xFFCCCCCC);
  static const _strokeWidth = 1.5;

  Path _buildPath(Size size) {
    const r = _radius;
    const th = _tailHeight;
    const thw = _tailHalfWidth;
    final bb = size.height - th;
    final tx = tailCenterX.clamp(thw + r, size.width - thw - r);

    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, bb - r)
      ..arcToPoint(Offset(size.width - r, bb), radius: const Radius.circular(r))
      ..lineTo(tx + thw, bb)
      ..lineTo(tx, bb + th)
      ..lineTo(tx - thw, bb)
      ..lineTo(r, bb)
      ..arcToPoint(Offset(0, bb - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_SpeechBubblePainter old) =>
      old.tailCenterX != tailCenterX;
}

class _DescriptionText extends StatelessWidget {
  const _DescriptionText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '위시템을 담으면 솜사탕이 생겨요.\n맑은 날엔 너굴이가 솜사탕을 맛있게 먹을 수 있어요!',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E1E1E),
        height: 1.5,
        letterSpacing: -0.22,
      ),
    );
  }
}
