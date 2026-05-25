import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<bool> showReportModal(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _ReportDialog(),
  );
  return result == true;
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _cancelPressed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
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
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 32.0),
          vertical: (31 * scale).clamp(24.0, 40.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이 글을 신고하시겠습니까?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: (20 * scale).clamp(16.0, 24.0),
                      color: AppColors.textPrimary,
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '※ 운영 원칙에 위배되는 게시물인지 확인 후 조치됩니다.\n허위 신고 시 서비스 이용에 제한이 있을 수 있습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: (13 * scale).clamp(11.0, 16.0),
                      color: const Color(0xFF979797),
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    '신고하시는 이유를 작성해주세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (16 * scale).clamp(13.0, 20.0),
                      color: const Color(0xFF444444),
                      height: 1.29,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: (25 * scale).clamp(18.0, 32.0),
                    vertical: (15 * scale).clamp(12.0, 19.0),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: (18 * scale).clamp(14.0, 22.0),
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '텍스트 입력하기',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (18 * scale).clamp(14.0, 22.0),
                        color: const Color(0xFFADADAD),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
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
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: _hasText ? () => Navigator.of(context).pop(true) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: _hasText ? AppColors.red_600 : AppColors.grey_100,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: _hasText ? AppColors.white : AppColors.textPrimary,
                        ),
                        child: const Text('신고접수'),
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
