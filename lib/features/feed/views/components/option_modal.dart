import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showOptionModal(
  BuildContext context, {
  required bool isMyPost,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _OptionModalContent(isMyPost: isMyPost),
  );
}

class _OptionModalContent extends StatelessWidget {
  const _OptionModalContent({required this.isMyPost});

  final bool isMyPost;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 25;

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
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 32.0),
          vertical: (31 * scale).clamp(24.0, 40.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isMyPost
              ? _myPostOptions(context, scale)
              : _othersPostOptions(context, scale),
        ),
      ),
    );
  }

  List<Widget> _myPostOptions(BuildContext context, double scale) => [
        _OptionButton(
          label: '수정하기',
          defaultColor: AppColors.skyBlue_100,
          pressedColor: AppColors.skyBlue_200,
          textColor: AppColors.textPrimary,
          onTap: () => Navigator.of(context).pop('edit'),
        ),
        SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
        _OptionButton(
          label: '삭제하기',
          defaultColor: AppColors.grey_100,
          pressedColor: AppColors.grey_300,
          textColor: AppColors.textPrimary,
          onTap: () => Navigator.of(context).pop('delete'),
        ),
      ];

  List<Widget> _othersPostOptions(BuildContext context, double scale) => [
        _OptionButton(
          label: '신고하기',
          defaultColor: AppColors.red_600,
          pressedColor: AppColors.red_500,
          textColor: AppColors.white,
          onTap: () => Navigator.of(context).pop('report'),
        ),
        SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
        _OptionButton(
          label: '차단하기',
          defaultColor: AppColors.grey_100,
          pressedColor: AppColors.grey_300,
          textColor: AppColors.textPrimary,
          onTap: () => Navigator.of(context).pop('block'),
        ),
      ];
}

class _OptionButton extends StatefulWidget {
  const _OptionButton({
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
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
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
        padding: EdgeInsets.symmetric(vertical: (15 * scale).clamp(12.0, 19.0)),
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
            fontSize: (20 * scale).clamp(16.0, 24.0),
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
