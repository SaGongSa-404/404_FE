import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class NugulLoadingScreen extends StatelessWidget {
  const NugulLoadingScreen({
    super.key,
    this.message = '잠시만 기다려주세요',
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
            const NugulLoadingIndicator(),
            SizedBox(height: 24 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              strutStyle: StrutStyle(
                fontSize: 18 * scale,
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
                fontSize: 18 * scale,
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

class NugulLoadingIndicator extends StatelessWidget {
  const NugulLoadingIndicator({
    super.key,
    this.ringSize,
    this.imageSize,
    this.strokeWidth,
  });

  final double? ringSize;
  final double? imageSize;
  final double? strokeWidth;

  static const _ringTrackColor = AppColors.grey_e6;
  static const _ringProgressColor = Color(0xFFB0CFDF);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final resolvedRingSize = ringSize ?? 120 * scale;
    final resolvedImageSize = imageSize ?? 84 * scale;
    final resolvedStrokeWidth = strokeWidth ?? 8 * scale;

    return SizedBox(
      width: resolvedRingSize,
      height: resolvedRingSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: resolvedRingSize,
            height: resolvedRingSize,
            child: CircularProgressIndicator(
              strokeWidth: resolvedStrokeWidth,
              backgroundColor: _ringTrackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_ringProgressColor),
            ),
          ),
          Image.asset(
            'assets/images/nugul_loading.png',
            width: resolvedImageSize,
            height: resolvedImageSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
