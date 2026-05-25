import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showCommentOptionModal(
  BuildContext context, {
  required bool isMyComment,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _CommentOptionContent(isMyComment: isMyComment),
  );
}

class _CommentOptionContent extends StatelessWidget {
  const _CommentOptionContent({required this.isMyComment});

  final bool isMyComment;

  @override
  Widget build(BuildContext context) {
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 27;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalInset,
        0,
        horizontalInset,
        bottomPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 3,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isMyComment
              ? [
                  _PressableButton(
                    label: '삭제하기',
                    defaultColor: AppColors.red_600,
                    pressedColor: AppColors.red_600,
                    textColor: AppColors.white,
                    onTap: () => Navigator.of(context).pop('delete'),
                  ),
                ]
              : [
                  _PressableButton(
                    label: '신고하기',
                    defaultColor: AppColors.red_600,
                    pressedColor: AppColors.red_600,
                    textColor: AppColors.white,
                    onTap: () => Navigator.of(context).pop('report'),
                  ),
                  const SizedBox(height: 12),
                  _PressableButton(
                    label: '차단하기',
                    defaultColor: AppColors.grey_100,
                    pressedColor: AppColors.grey_300,
                    textColor: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).pop('block'),
                  ),
                ],
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.label,
    required this.defaultColor,
    required this.pressedColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color defaultColor;
  final Color pressedColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _pressed ? widget.pressedColor : widget.defaultColor,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
