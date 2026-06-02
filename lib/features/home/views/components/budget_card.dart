import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/profile/providers/consumption_stats_provider.dart';
import 'package:fe_app/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final statsState = ref.watch(consumptionStatsProvider);
    final current = statsState.currentMonthStats;

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) =>
        val.toString().replaceAllMapped(numberFormat, (m) => ',');

    if (statsState.isLoading && current == null) {
      return SizedBox(
        height: 120 * scale,
        child: const Center(child: LoadingIndicator(compact: true)),
      );
    }

    if (current == null) {
      return const SizedBox.shrink();
    }

    final isExceeded = current.isExceeded;
    final remaining = current.budgetAmount - current.spentAmount;
    final progress = current.progressFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '이번 달 예산 현황',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/my/consumption'),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        Text(
          isExceeded ? '예산 초과!' : '${format(remaining)}원 남음',
          style: TextStyle(
            color: isExceeded ? AppColors.red_400 : AppColors.textPrimary,
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20 * scale),
        Container(
          height: 16 * scale,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isExceeded ? AppColors.red_200 : AppColors.skyBlue_200,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${format(current.spentAmount)}원',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12 * scale,
              ),
            ),
            Text(
              '${format(current.budgetAmount)}원',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12 * scale,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
