import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showOptionModal(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _OptionModalContent(),
  );
}

class _OptionModalContent extends StatelessWidget {
  const _OptionModalContent();

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
          children: [
            _OptionButton(
              label: '수정하기',
              color: AppColors.skyBlue_100,
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            const SizedBox(height: 12),
            _OptionButton(
              label: '삭제하기',
              color: AppColors.greyButton,
              onTap: () => Navigator.of(context).pop('delete'),
            ),
            const SizedBox(height: 12),
            _OptionButton(
              label: '공유하기',
              color: AppColors.yellow,
              onTap: () => Navigator.of(context).pop('share'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
