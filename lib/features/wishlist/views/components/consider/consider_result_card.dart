import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/viewmodels/consider_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsiderResultCard extends ConsumerWidget {
  const ConsiderResultCard({super.key});

  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final state = ref.watch(considerViewModelProvider);

    return Column(
      children: [
        Text(
          '지금까지 확인한 내용',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16 * scale),
        DecoratedBox(
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
            padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 16 * scale),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ResultMetric(
                      value: state.budgetPercent,
                      label: '예산사용',
                      scale: scale,
                    ),
                  ),
                  _VerticalDivider(scale: scale),
                  Expanded(
                    child: _ResultMetric(
                      value: '${state.yesCount}개',
                      label: '비합리 답변',
                      scale: scale,
                    ),
                  ),
                  _VerticalDivider(scale: scale),
                  Expanded(
                    child: _ResultMetric(
                      value: state.opportunityCost,
                      label: '기회비용',
                      scale: scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '💡 나중에 마음이 바뀌면 소비관리에서 수정할 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7B7B7B),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.value,
    required this.label,
    required this.scale,
  });

  final String value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            height: 1.2,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7B7B7B),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.2,
      margin: EdgeInsets.symmetric(vertical: 1 * scale),
      color: AppColors.grey_e6,
    );
  }
}
