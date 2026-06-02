import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionRateCard extends ConsumerWidget {
  const SelectionRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);

    return ref.watch(homeSummaryProvider).when(
          data: (summary) {
            final rate = (summary?.rationalChoiceRate ?? 0).clamp(0.0, 100.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '합리적 선택률',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 14 * scale,
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 80 * scale,
                      height: 80 * scale,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: rate / 100,
                            strokeWidth: 10 * scale,
                            backgroundColor: const Color(0xFFF2F2F2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BA9C2)),
                          ),
                          Center(
                            child: Text(
                              '${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 1)}%',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => _placeholder(scale, '선택률 정보를 불러오는 중이에요.'),
          error: (_, __) => _placeholder(scale, '선택률 정보를 불러오지 못했어요.'),
        );
  }

  Widget _placeholder(double scale, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12 * scale,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
