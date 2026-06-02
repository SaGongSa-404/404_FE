import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
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
    final summaryAsync = ref.watch(homeSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();

        final budget = summary.budget;
        final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
        String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');
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

        final isExceeded = budget.isBudgetExhausted || budget.remainingAmount <= 0;

        final progress = isExceeded
            ? 1.0
            : budget.monthlyBudgetAmount <= 0
            ? 0.0
            : (budget.spentAmount / budget.monthlyBudgetAmount).clamp(0.0, 1.0);

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
                    color: const Color(0xFFADADAD),
                    size: 14 * scale,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6 * scale),
            Text(
              '${format(budget.remainingAmount)}원 남음',
              style: TextStyle(
                color: isExceeded ? const Color(0xFFD46868) : AppColors.textPrimary,
                fontSize: 24 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 28 * scale),

            Container(
              height: 12 * scale,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              clipBehavior: Clip.hardEdge,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isExceeded
                        ? const Color(0xFFD46868)
                        : const Color(0xFFC1D8E8),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${format(budget.spentAmount)}원',
                  style: TextStyle(
                    color: const Color(0xFFADADAD),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${format(budget.monthlyBudgetAmount)}원',
                  style: TextStyle(
                    color: const Color(0xFFADADAD),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, _) => Center(
        child: Text(
          '예산 데이터를 불러올 수 없습니다.',
          style: TextStyle(fontSize: 12 * scale, color: Colors.grey),
        ),
      ),
    );
  }
}
