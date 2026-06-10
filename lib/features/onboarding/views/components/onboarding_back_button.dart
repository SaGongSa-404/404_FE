import 'package:flutter/material.dart';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/onboarding/views/components/onboarding_layout.dart';

class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onTap,
        tooltip: '뒤로 가기',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        iconSize: OnboardingLayout.backIconSize,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
