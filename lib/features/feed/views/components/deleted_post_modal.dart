import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 삭제됐거나 비공개 처리된 게시글에 진입하려 할 때 띄우는 하단 안내 모달.
Future<void> showDeletedPostModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _DeletedPostSheet(),
  );
}

class _DeletedPostSheet extends StatefulWidget {
  const _DeletedPostSheet();

  @override
  State<_DeletedPostSheet> createState() => _DeletedPostSheetState();
}

class _DeletedPostSheetState extends State<_DeletedPostSheet> {
  bool _confirmPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 412;
    final horizontalInset = 21 * scale;

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
          borderRadius: BorderRadius.circular(37 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 31 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '게시물을 찾을 수 없어요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20 * scale,
                      color: const Color(0xFF1A1A1A),
                      height: 1.29,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    '삭제되었거나 비공개 처리된 위시예요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16 * scale,
                      color: const Color(0xFF979797),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27 * scale),
            GestureDetector(
              onTapDown: (_) => setState(() => _confirmPressed = true),
              onTapUp: (_) {
                setState(() => _confirmPressed = false);
                Navigator.of(context).pop();
              },
              onTapCancel: () => setState(() => _confirmPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: double.infinity,
                height: 57 * scale,
                decoration: BoxDecoration(
                  color: _confirmPressed
                      ? AppColors.skyBlue_200
                      : AppColors.skyBlue_100,
                  borderRadius: BorderRadius.circular(57 * scale),
                ),
                alignment: Alignment.center,
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20 * scale,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
