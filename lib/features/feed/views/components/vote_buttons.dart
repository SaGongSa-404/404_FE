import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/feed/models/vote_type.dart';
import 'package:flutter/material.dart';

class VoteButtons extends StatelessWidget {
  const VoteButtons({
    super.key,
    required this.myVote,
    required this.goCount,
    required this.stopCount,
    required this.onVote,
    this.isDisabled = false,
  });

  final VoteType? myVote;
  final int goCount;
  final int stopCount;
  final ValueChanged<VoteType> onVote;
  final bool isDisabled;

  int get _total => goCount + stopCount;

  String _percent(int count) {
    if (_total == 0) {
      // 본인 글(투표 비활성)은 0표여도 항상 카운트 노출
      return isDisabled ? '$count명' : '';
    }
    return '${(count / _total * 100).round()}%($count명)';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final hasVoted = myVote != null;
    final showPercent = isDisabled || hasVoted;

    final buttons = Row(
      children: [
        Expanded(
          child: _VoteButton(
            label: 'GO',
            activeColor: AppColors.skyBlue_100,
            isSelected: isDisabled || myVote == VoteType.go,
            isDimmed: !isDisabled && myVote == VoteType.stop,
            percentText: showPercent ? _percent(goCount) : '',
            onTap: () => onVote(VoteType.go),
          ),
        ),
        SizedBox(width: (12 * scale).clamp(9.0, 15.0)),
        Expanded(
          child: _VoteButton(
            label: 'STOP',
            activeColor: AppColors.yellow,
            isSelected: isDisabled || myVote == VoteType.stop,
            isDimmed: !isDisabled && myVote == VoteType.go,
            percentText: showPercent ? _percent(stopCount) : '',
            onTap: () => onVote(VoteType.stop),
          ),
        ),
      ],
    );

    if (isDisabled) {
      return IgnorePointer(child: buttons);
    }
    return buttons;
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.label,
    required this.activeColor,
    required this.isSelected,
    required this.isDimmed,
    required this.percentText,
    required this.onTap,
  });

  final String label;
  final Color activeColor;
  final bool isSelected;
  final bool isDimmed;
  final String percentText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final bgColor = isDimmed ? AppColors.background : activeColor;
    final border = isDimmed ? null : Border.all(color: activeColor, width: 2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: (10 * scale).clamp(8.0, 12.0),
          horizontal: (8 * scale).clamp(6.0, 10.0),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: (18 * scale).clamp(14.0, 22.0),
                color: AppColors.textDark,
              ),
            ),
            if (percentText.isNotEmpty) ...[
              SizedBox(width: (12 * scale).clamp(9.0, 15.0)),
              Flexible(
                child: Text(
                  percentText,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: (12 * scale).clamp(9.0, 15.0),
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
