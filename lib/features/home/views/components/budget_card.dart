import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final summaryAsync = ref.watch(homeSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();

        final budget = summary.budget;

        final monthlyBudgetAmount = budget.monthlyBudgetAmount;
        final spentAmount = budget.spentAmount;
        final remainingAmount = budget.remainingAmount;

        final isBudgetExceeded =
            monthlyBudgetAmount > 0 && spentAmount > monthlyBudgetAmount;
        final isBudgetZero = !isBudgetExceeded && remainingAmount == 0;
        final isBudgetAlert = isBudgetZero || isBudgetExceeded;
        final exceededAmount =
            isBudgetExceeded ? (spentAmount - monthlyBudgetAmount) : 0;
        const alertColor = Color(0xFFB26D6D);

        final progress = monthlyBudgetAmount <= 0
            ? 0.0
            : (spentAmount / monthlyBudgetAmount).clamp(0.0, 1.0);

        String format(int value) {
          return value.toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (match) => ',',
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20 * scale),
            onTap: onTap ?? () => context.push('/my/consumption'),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2 * scale,
                vertical: 2 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 달 예산 현황',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: const Color(0xFF555555),
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: isBudgetExceeded
                              ? '${format(exceededAmount)}원'
                              : '${format(remainingAmount)}원',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: isBudgetAlert
                                ? alertColor
                                : const Color(0xFF333333),
                            fontSize: 27 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                          ),
                        ),
                        TextSpan(
                          text: isBudgetExceeded ? ' 초과' : ' 남음',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: isBudgetAlert
                                ? alertColor
                                : const Color(0xFF7B7B7B),
                            fontSize: 17 * scale,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 18 * scale,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(
                            color: const Color(0xFFEEEEEE),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              color: isBudgetAlert
                                  ? alertColor
                                  : const Color(0xFF6D96B2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${format(spentAmount)}원',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: const Color(0xFF555555),
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${format(monthlyBudgetAmount)}원',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: const Color(0xFF555555),
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Center(
        child: Text(
          '예산 데이터를 불러올 수 없습니다.',
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}