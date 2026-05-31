import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class ConsiderInsightCards extends StatelessWidget {
  const ConsiderInsightCards({
    super.key,
    this.opportunityCostValue = '라떼 6잔',
    this.opportunityCostDescription = '25,000원으로\n살 수 있어요',
    this.spendingHistoryValue = '0원',
    this.spendingHistoryDescription = '지난 달 패션\n구매 이력이 없어요',
  });

  final String opportunityCostValue;
  final String opportunityCostDescription;
  final String spendingHistoryValue;
  final String spendingHistoryDescription;

  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InsightCard(
            title: '기회비용',
            value: opportunityCostValue,
            description: opportunityCostDescription,
            scale: scale,
            borderRadius: _cardBorderRadius,
            shadowColor: _cardShadowColor,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _InsightCard(
            title: '소비이력',
            value: spendingHistoryValue,
            description: spendingHistoryDescription,
            scale: scale,
            borderRadius: _cardBorderRadius,
            shadowColor: _cardShadowColor,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.description,
    required this.scale,
    required this.borderRadius,
    required this.shadowColor,
  });

  final String title;
  final String value;
  final String description;
  final double scale;
  final double borderRadius;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius * scale),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              value,
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
                height: 1.2,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              description,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
