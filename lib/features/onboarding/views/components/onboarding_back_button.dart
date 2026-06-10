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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: OnboardingLayout.backIconSize,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
