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
        const alertColor = Color(0xFFB26D6D);

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
                          text: budget.isBudgetExceeded
                              ? '${format(budget.exceededAmount)}원'
                              : '${format(budget.remainingAmount)}원',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: budget.isBudgetAlert
                                ? alertColor
                                : const Color(0xFF333333),
                            fontSize: 27 * scale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                          ),
                        ),
                        TextSpan(
                          text: budget.isBudgetExceeded ? ' 초과' : ' 남음',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: budget.isBudgetAlert
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
                            widthFactor: budget.progress,
                            child: Container(
                              color: budget.isBudgetAlert
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
                        '${format(budget.spentAmount)}원',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: const Color(0xFF555555),
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${format(budget.monthlyBudgetAmount)}원',
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