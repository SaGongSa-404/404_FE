import 'package:fe_app/core/theme/app_theme.dart';
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
    return Row(
      children: [
        Expanded(
          child: _FeedbackOption(
            emoji: '😊',
            label: '잘했어요',
            selected: selected == ReflectFeedback.good,
            onTap: () => onSelected(ReflectFeedback.good),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeedbackOption(
            emoji: '🤔',
            label: '그냥 그래요',
            selected: selected == ReflectFeedback.neutral,
            onTap: () => onSelected(ReflectFeedback.neutral),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeedbackOption(
            emoji: '😭',
            label: '후회해요',
            selected: selected == ReflectFeedback.regret,
            onTap: () => onSelected(ReflectFeedback.regret),
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
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: AppColors.skyBlue_200, width: 1.6)
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
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          highlightColor: AppColors.grey_e6.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 27, height: 1.1)),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
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
