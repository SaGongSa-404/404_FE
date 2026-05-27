import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/home/providers/home_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final state = ref.watch(homeSummaryProvider);

    if (state.isLoading) {
      return _Placeholder(scale: scale, message: '예산 정보를 불러오는 중이에요.');
    }

    final error = state.error;
    if (error != null) {
      return _ErrorView(
        scale: scale,
        onRetry: () => ref.read(homeSummaryProvider.notifier).refresh(),
      );
    }

    final summary = state.valueOrNull;
    final budget = summary?.budget;
    if (budget == null) {
      return _Placeholder(scale: scale, message: '예산 정보를 불러오지 못했어요.');
    }

    final numberFormat = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String format(int val) => val.toString().replaceAllMapped(numberFormat, (m) => ',');

    final isExceeded = budget.isBudgetExhausted;
    final progress = budget.monthlyBudgetAmount <= 0
        ? 0.0
        : (budget.spentAmount / budget.monthlyBudgetAmount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 달 예산',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          '${format(budget.remainingAmount)}원 남았어요',
          style: TextStyle(
            color: isExceeded ? AppColors.red_200 : AppColors.textPrimary,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          '${budget.yearMonth} · 총 ${format(budget.monthlyBudgetAmount)}원',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12 * scale,
          ),
        ),
        SizedBox(height: 14 * scale),
        Container(
          height: 12 * scale,
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
              '${format(budget.spentAmount)}원',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12 * scale,
              ),
            ),
            Text(
              '${format(budget.monthlyBudgetAmount)}원',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12 * scale,
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        TextButton(
          onPressed: () => context.go('/my/consumption'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            '소비관리 자세히 보기',
            style: TextStyle(
              fontSize: 12 * scale,
              color: AppColors.skyBlue_100,
            ),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.scale, required this.message});

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140 * scale,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13 * scale,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.scale, required this.onRetry});

  final double scale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140 * scale,
      child: Center(
        child: TextButton(
          onPressed: onRetry,
          child: Text(
            '예산 정보를 다시 불러오기',
            style: TextStyle(fontSize: 13 * scale),
          ),
        ),
      ),
    );
  }
}
