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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        31,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              '해당 상품의 링크로 이동할까요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.textDark,
                height: 1.29,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  SvgPicture.asset(
                    _dontShowAgain
                        ? 'assets/images/link_check_clicked.svg'
                        : 'assets/images/link_check.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '앞으로 이 창을 표시하지 않음',
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
          ),
          const SizedBox(height: 27),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: _onConfirm,
                  child: Container(
                    height: 57,
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue_100,
                      borderRadius: BorderRadius.circular(57),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
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
    );
  }
}
