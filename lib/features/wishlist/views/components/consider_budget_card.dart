import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/wishlist/models/wishlist/wishlist_category_ui.dart';
import 'package:fe_app/features/wishlist/utils/price_format.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';

class ConsiderBudgetCard extends ConsumerWidget {
  const ConsiderBudgetCard({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(considerViewModelProvider(itemId));
    final data = state.deliberation;
    if (data == null) return const SizedBox.shrink();

    final budget = data.budget;
    final item = data.item;
    final usageRate = (budget.projectedUsageRate / 100).clamp(0.0, 1.0);
    final additionalSpend =
        (budget.projectedSpentAmount - budget.spentAmount).round();
    final categoryLabel = WishlistCategoryUi.toUiLabel(item.category);
    final statusLabel = deliberationBudgetStatusLabel(budget.projectedUsageRate);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '다음 달 예산',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${formatKrwAmount(budget.monthlyBudgetAmount)}원',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: usageRate.toDouble(),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.red_200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '현재 ${formatKrwAmount(budget.spentAmount)}원',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (additionalSpend > 0) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 8, color: AppColors.red_200),
                    const SizedBox(width: 4),
                    Text(
                      '+${formatKrwAmount(additionalSpend)}원',
                      style: AppTextStyles.body
                          .copyWith(fontSize: 12, color: AppColors.red_200),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '예산의 ${budget.projectedUsageRate.round()}%',
                    style: AppTextStyles.heading.copyWith(fontSize: 20),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue_000_clicked,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.skyBlue_300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                '기회비용',
                item.listedPrice != null && item.listedPrice! > 0
                    ? '${formatKrwAmount(item.listedPrice!)}원'
                    : '-',
                data.opportunityCostMessage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                '소비이력',
                '${formatKrwAmount(data.similarCategorySpendAmount)}원',
                deliberationSimilarSpendSubtitle(
                  categoryLabel: categoryLabel,
                  amount: data.similarCategorySpendAmount,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body
                .copyWith(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.body
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
