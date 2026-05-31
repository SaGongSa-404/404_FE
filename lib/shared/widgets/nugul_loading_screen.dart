import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/onboarding/views/components/nugul_video.dart';
import 'package:flutter/material.dart';

/// API·목록 로딩 시 너굴 영상을 보여주는 공통 로딩 UI.
class NugulLoadingScreen extends StatelessWidget {
  const NugulLoadingScreen({
    super.key,
    this.message,
    this.backgroundColor,
    this.compact = false,
  });

  final String? message;
  final Color? backgroundColor;

  /// 목록 하단 등 좁은 영역용 (영상 크기 축소).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final nugulSize = compact
        ? (72 * scale).clamp(56.0, 88.0)
        : (150 * scale).clamp(120.0, 180.0);

    return ColoredBox(
      color: backgroundColor ?? AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NugulVideo(size: nugulSize),
            if (message != null) ...[
              SizedBox(height: (16 * scale).clamp(12.0, 20.0)),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: (16 * scale).clamp(13.0, 19.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
