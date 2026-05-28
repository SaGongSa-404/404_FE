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
    final scale = MediaQuery.of(context).size.width / 412.0;
    final horizontalInset = MediaQuery.of(context).size.width * 21 / 412;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 31;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이 사용자를 차단하시겠습니까?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: (20 * scale).clamp(16.0, 24.0),
                      color: AppColors.textPrimary,
                      height: 1.29,
                    ),
                  ),
                  SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
                  Text(
                    '차단 후에는 이 사용자가 작성한 모든 게시글과\n댓글을 더 이상 볼 수 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (16 * scale).clamp(13.0, 20.0),
                      color: const Color(0xFF979797),
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
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
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: _cancelPressed ? AppColors.grey_300 : AppColors.grey_100,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
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
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: _blockPressed
                            ? AppColors.red_500
                            : AppColors.red_600,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '차단',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
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
