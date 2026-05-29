import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showProductLinkDialog({
  required BuildContext context,
  required String? productUrl,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => _ProductLinkBottomSheet(productUrl: productUrl),
  );
}

class _ProductLinkBottomSheet extends StatefulWidget {
  const _ProductLinkBottomSheet({required this.productUrl});

  final String? productUrl;

  @override
  State<_ProductLinkBottomSheet> createState() =>
      _ProductLinkBottomSheetState();
}

class _ProductLinkBottomSheetState extends State<_ProductLinkBottomSheet> {
  bool _dontShowAgain = false;

  Future<void> _onConfirm() async {
    Navigator.of(context).pop();
    if (widget.productUrl == null) return;
    final uri = Uri.parse(widget.productUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 412.0;
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
          borderRadius: BorderRadius.circular((22 * scale).clamp(17.0, 27.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (24 * scale).clamp(18.0, 30.0),
          vertical: (31 * scale).clamp(24.0, 38.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
              child: Text(
                '해당 상품의 링크로 이동할까요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: (20 * scale).clamp(16.0, 24.0),
                  color: AppColors.textDark,
                  height: 1.29,
                ),
              ),
            ),
            SizedBox(height: (12 * scale).clamp(9.0, 15.0)),
            GestureDetector(
              onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: (7 * scale).clamp(5.0, 9.0)),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _dontShowAgain
                          ? 'assets/images/link_check_clicked.svg'
                          : 'assets/images/link_check.svg',
                      width: (20 * scale).clamp(16.0, 24.0),
                      height: (20 * scale).clamp(16.0, 24.0),
                    ),
                    SizedBox(width: (5 * scale).clamp(4.0, 6.0)),
                    Text(
                      '앞으로 이 창을 표시하지 않음',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: (16 * scale).clamp(13.0, 19.0),
                        color: const Color(0xFF979797),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: (27 * scale).clamp(21.0, 33.0)),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (6 * scale).clamp(4.0, 8.0)),
                Expanded(
                  child: GestureDetector(
                    onTap: _onConfirm,
                    child: Container(
                      height: (57 * scale).clamp(46.0, 68.0),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue_100,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: (20 * scale).clamp(16.0, 24.0),
                          color: AppColors.textDark,
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
