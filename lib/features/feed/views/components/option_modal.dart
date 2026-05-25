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
          children: isMyPost ? _myPostOptions(context) : _othersPostOptions(context),
        ),
      ),
    );
  }

  List<Widget> _myPostOptions(BuildContext context) => [
        _OptionButton(
          label: '수정하기',
          bgColor: AppColors.skyBlue_200,
          textColor: AppColors.white,
          onTap: () => Navigator.of(context).pop('edit'),
        ),
        const SizedBox(height: 12),
        _OptionButton(
          label: '삭제하기',
          bgColor: AppColors.red_600,
          textColor: AppColors.white,
          onTap: () => Navigator.of(context).pop('delete'),
        ),
        const SizedBox(height: 12),
        _OptionButton(
          label: '공유하기',
          bgColor: AppColors.yellow_100,
          textColor: AppColors.textPrimary,
          onTap: () => Navigator.of(context).pop('share'),
        ),
      ];

  List<Widget> _othersPostOptions(BuildContext context) => [
        _OptionButton(
          label: '신고하기',
          bgColor: AppColors.red_600,
          textColor: AppColors.white,
          onTap: () => Navigator.of(context).pop('report'),
        ),
        const SizedBox(height: 12),
        _OptionButton(
          label: '차단하기',
          bgColor: AppColors.grey_300,
          textColor: AppColors.textPrimary,
          onTap: () => Navigator.of(context).pop('block'),
        ),
      ];
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
