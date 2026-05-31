import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

enum ReflectFeedback { good, neutral, regret }

class ReflectFeedbackSelector extends StatelessWidget {
  const ReflectFeedbackSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ReflectFeedback? selected;
  final ValueChanged<ReflectFeedback> onSelected;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Row(
      children: [
        Expanded(
          child: _FeedbackOption(
            emoji: '😊',
            label: '잘했어요',
            selected: selected == ReflectFeedback.good,
            onTap: () => onSelected(ReflectFeedback.good),
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _FeedbackOption(
            emoji: '🤔',
            label: '그냥 그래요',
            selected: selected == ReflectFeedback.neutral,
            onTap: () => onSelected(ReflectFeedback.neutral),
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _FeedbackOption(
            emoji: '😭',
            label: '후회해요',
            selected: selected == ReflectFeedback.regret,
            onTap: () => onSelected(ReflectFeedback.regret),
            scale: scale,
          ),
        ),
      ],
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  static const Color _cardShadowColor = Color(0x22000000);

  const _FeedbackOption({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16 * scale),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: selected
              ? Border.all(color: AppColors.skyBlue_200, width: 1.6 * scale)
              : null,
          boxShadow: const [
            BoxShadow(
              color: _cardShadowColor,
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          splashColor: Colors.transparent,
          highlightColor: AppColors.grey_e6.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18 * scale,
              horizontal: 20 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 27 * scale, height: 1.1),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
