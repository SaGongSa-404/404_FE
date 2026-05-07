import 'package:flutter/material.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleFontSize = 30,
    this.titleHeight = 1.548,
    this.gap = 22,
  });

  final String title;
  final String subtitle;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final double titleFontSize;
  final double titleHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: titleHeight,
          ),
        ),
        SizedBox(height: gap),
        Text(
          subtitle,
          textAlign: textAlign,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
