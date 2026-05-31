import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class ConsiderBudgetCard extends StatelessWidget {
  const ConsiderBudgetCard({
    super.key,
    this.totalBudget = 500000,
    this.currentSpent = 90000,
    this.addedAmount = 29000,
    this.budgetPercent = '23%',
    this.statusLabel = '여유 있음',
  });

  final int totalBudget;
  final int currentSpent;
  final int addedAmount;
  final String budgetPercent;
  final String statusLabel;

  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);
  static const Color _currentSegmentColor = AppColors.skyBlue_100;
  static const Color _addedSegmentColor = AppColors.red_400;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final currentRatio = totalBudget > 0 ? currentSpent / totalBudget : 0.0;
    final addedRatio = totalBudget > 0 ? addedAmount / totalBudget : 0.0;
    final totalFillRatio = (currentRatio + addedRatio).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius * scale),
        boxShadow: const [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 22 * scale, horizontal: 24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번 달 예산',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_formatPrice(totalBudget)}원',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final barHeight = 18 * scale;
                final radius = BorderRadius.circular(barHeight / 2);

                return SizedBox(
                  height: barHeight,
                  width: barWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: radius,
                        ),
                      ),
                      if (addedRatio > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: barWidth * totalFillRatio,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: _addedSegmentColor,
                              borderRadius: radius,
                            ),
                          ),
                        ),
                      if (currentRatio > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: barWidth * currentRatio,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: _currentSegmentColor,
                              borderRadius: radius,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 12 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LegendItem(
                  color: _currentSegmentColor,
                  label: '현재 ${_formatPrice(currentSpent)}원',
                  scale: scale,
                ),
                SizedBox(width: 18 * scale),
                _LegendItem(
                  color: _addedSegmentColor,
                  label: '+${_formatPrice(addedAmount)}원',
                  scale: scale,
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '예산의 $budgetPercent',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F3F9),
                    borderRadius: BorderRadius.circular(33 * scale),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6D96B2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.scale,
  });

  final Color color;
  final String label;
  final double scale;

  static const double _indicatorWidth = 14;
  static const double _indicatorHeight = 11;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _indicatorWidth * scale,
          height: _indicatorHeight * scale,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_indicatorHeight * scale / 2),
          ),
        ),
        SizedBox(width: 5 * scale),
        Text(
          label,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            height: 1,
          ),
        ),
      ],
    );
  }
}
