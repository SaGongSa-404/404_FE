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

Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _DeleteConfirmDialog(),
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

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalInset,
        0,
        horizontalInset,
        MediaQuery.of(context).padding.bottom + 24,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '작성한 게시글을\n정말 삭제하실 건가요?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      height: 1.29,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '한 번 삭제된 게시글은 되돌릴 수 없어요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF979797),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: AppColors.red_600,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '삭제하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.white,
                        ),
                      ),
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
}
