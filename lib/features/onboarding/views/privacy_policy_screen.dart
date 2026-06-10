import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/legal/widgets/privacy_policy_body.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_layout.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_spaced_scroll_view.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale =
                constraints.maxWidth / OnboardingLayout.designWidth;
            final hPad = (constraints.maxWidth * (24 / OnboardingLayout.designWidth))
                .clamp(20.0, 48.0);
            final headerHPad =
                (constraints.maxWidth * (28 / OnboardingLayout.designWidth))
                    .clamp(22.0, 56.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: OnboardingSpacedScrollView(
                  viewportHeight: constraints.maxHeight,
                  children: [
                    OnboardingLayout.topSpacer(),
                    _Header(
                      title: '개인정보 처리방침',
                      arrowSize: OnboardingLayout.backIconSize,
                      hPad: headerHPad,
                      bottomPad: (18 * scale).clamp(14.0, 22.0),
                      fontSize: (20 * scale).clamp(15.0, 26.0),
                      onBack: () => context.pop(),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        (17 * scale).clamp(12.0, 22.0),
                        hPad,
                        (80 * scale).clamp(48.0, 80.0),
                      ),
                      child: _PrivacyPolicyContent(scale: scale),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.arrowSize,
    required this.hPad,
    required this.bottomPad,
    required this.fontSize,
    required this.onBack,
  });

  final String title;
  final double arrowSize;
  final double hPad;
  final double bottomPad;
  final double fontSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(hPad, bottomPad, hPad, bottomPad),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/images/arrow_forward.svg',
                width: arrowSize,
                height: arrowSize,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(width: arrowSize + 8),
        ],
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final fontSize = (14 * scale).clamp(11.0, 18.0);

    final headingStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.548,
    );

    final bodyStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.548,
    );

    final gap = SizedBox(height: (14 * scale).clamp(10.0, 18.0));

    return PrivacyPolicyBody(
      headingStyle: headingStyle,
      bodyStyle: bodyStyle,
      sectionGap: gap,
    );
  }
}
