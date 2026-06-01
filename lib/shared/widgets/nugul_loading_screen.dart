import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class NugulLoadingScreen extends StatelessWidget {
  const NugulLoadingScreen({
    super.key,
    this.message = '잠시만 기다려주시구리',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NugulLoadingDots(),
            SizedBox(height: 25 * scale),
            Image.asset(
              'assets/images/nugul_loading.png',
              width: 132 * scale,
              height: 132 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 25 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              strutStyle: StrutStyle(
                fontSize: 20 * scale,
                height: 1.35,
                leading: 0,
                forceStrutHeight: true,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                height: 1.35,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NugulLoadingDots extends StatefulWidget {
  const _NugulLoadingDots();

  @override
  State<_NugulLoadingDots> createState() => _NugulLoadingDotsState();
}

class _NugulLoadingDotsState extends State<_NugulLoadingDots>
    with SingleTickerProviderStateMixin {
  static const _dotColors = [
    Color(0xFFDBC4C2),
    Color(0xFFBC9893),
    Color(0xFF875A54),
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final dotSize = 12 * scale;
    final dotGap = 12 * scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_dotColors.length, (index) {
            final phase = (_controller.value + index / _dotColors.length) % 1.0;
            final emphasis = Curves.easeInOut.transform(
              phase < 0.5 ? phase * 2 : (1 - phase) * 2,
            );
            final scaleFactor = 0.75 + emphasis * 0.25;
            final opacity = 0.45 + emphasis * 0.55;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dotGap / 2),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scaleFactor,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: _dotColors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
