import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class SelectionRateCard extends StatelessWidget {
  const SelectionRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '합리적 선택률',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20 * scale),
        Center(
          child: SizedBox(
            width: 100 * scale,
            height: 100 * scale,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 12 * scale,
                  backgroundColor: const Color(0xFFF2F2F2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BA9C2)),
                ),
                Center(
                  child: Text(
                    '78%',
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
