import 'package:flutter/material.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class SelectionRateCard extends StatelessWidget {
  const SelectionRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '합리적 선택률',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFF2F2F2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BA9C2)),
                ),
                const Center(
                  child: Text(
                    '78%',
                    style: TextStyle(
                      fontSize: 20,
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
