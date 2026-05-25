import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<bool> showBlockModal(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _BlockDialog(),
  );
  return result == true;
}

class _BlockDialog extends StatefulWidget {
  const _BlockDialog();

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  bool _cancelPressed = false;
  bool _blockPressed = false;

  @override
  Widget build(BuildContext context) {
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '이 사용자를 차단하시겠습니까?',
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
                    '차단 후에는 이 사용자가 작성한 모든 게시글과\n댓글을 더 이상 볼 수 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF979797),
                      height: 1.33,
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
                    onTapDown: (_) => setState(() => _cancelPressed = true),
                    onTapUp: (_) {
                      setState(() => _cancelPressed = false);
                      Navigator.of(context).pop(false);
                    },
                    onTapCancel: () => setState(() => _cancelPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 57,
                      decoration: BoxDecoration(
                        color: _cancelPressed ? AppColors.grey_300 : AppColors.grey_100,
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
                    onTapDown: (_) => setState(() => _blockPressed = true),
                    onTapUp: (_) {
                      setState(() => _blockPressed = false);
                      Navigator.of(context).pop(true);
                    },
                    onTapCancel: () => setState(() => _blockPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 57,
                      decoration: BoxDecoration(
                        color: _blockPressed
                            ? AppColors.red_600.withValues(alpha: 0.75)
                            : AppColors.red_600,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '차단',
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
