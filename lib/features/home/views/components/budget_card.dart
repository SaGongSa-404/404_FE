import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/models/home_summary.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    this.summary,
    this.onTap,
  });

  final HomeSummaryResponse? summary;
  final VoidCallback? onTap;

  static const Color _progressFill = Color(0xFF6D96B2);
  static const Color _progressTrack = Color(0xFFEEEEEE);
  static const Color _alertColor = Color(0xFFB26D6D);
  static const Color _suffixColor = Color(0xFF7B7B7B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final data = summary ?? ref.watch(homeSummaryProvider).valueOrNull;
    if (data == null) return const SizedBox.shrink();

    final budget = data.budget;

    String format(int value) {
      return value.toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
          );
    }

    final amountColor =
        budget.isBudgetAlert ? _alertColor : const Color(0xFF333333);
    final progressColor = budget.isBudgetAlert ? _alertColor : _progressFill;
    final amountText = budget.isBudgetExceeded
        ? '${format(budget.exceededAmount)}원'
        : '${format(budget.remainingAmount)}원';
    final suffixText = budget.isBudgetExceeded ? '초과' : '남음';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22 * scale),
        onTap: onTap ?? () => context.push('/my/consumption'),
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
                height: 1.2,
              ),
            ),
            SizedBox(height: 12 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: amountColor,
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: 9 * scale),
                Text(
                  suffixText,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color:
                        budget.isBudgetExceeded ? _alertColor : _suffixColor,
                    fontSize: 17 * scale,
                    fontWeight: FontWeight.w500,
                    height: 26.32 / 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: 23 * scale),
            LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final barHeight = 16 * scale;
                final radius = BorderRadius.circular(barHeight / 2);
                final progress = budget.progress.clamp(0.0, 1.0);

                var fillWidth = barWidth * progress;
                if (progress > 0 && fillWidth < barHeight) {
                  fillWidth = barHeight;
                }

                return SizedBox(
                  height: barHeight,
                  width: barWidth,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Container(
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: _progressTrack,
                          borderRadius: radius,
                        ),
                      ),
                      if (fillWidth > 0)
                        Container(
                          width: fillWidth.clamp(0.0, barWidth),
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: radius,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 12 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${format(budget.spentAmount)}원',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: const Color(0xFF555555),
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${format(budget.monthlyBudgetAmount)}원',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: const Color(0xFF555555),
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
