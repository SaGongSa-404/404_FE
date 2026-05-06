import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showWishlistShareToFeedModal(
  BuildContext context, {
  VoidCallback? onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x59000000),
    builder: (dialogContext) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(24, 23, 24, 23),
        child: _WishlistShareModalPanel(onConfirm: onConfirm),
      );
    },
  );
}

class _WishlistShareModalPanel extends StatelessWidget {
  const _WishlistShareModalPanel({this.onConfirm});

  final VoidCallback? onConfirm;

  static const Color _cancelButtonBg = AppColors.grey;
  static const Color _shareButtonBg = AppColors.skyBlue_100;
  static const double _pillHeight = 52;
  static const double _radius = 37;
  static const double _buttonRadius = 999;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 37,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 23, 24, 23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '피드에 공유하시겠습니까?',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '위시리스트를 공유하고 여러 사람들에게 조언을 구해보세요!',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 27),
            Row(
              children: [
                Expanded(
                  child: _rowPillButton(
                    label: '취소',
                    background: _cancelButtonBg,
                    foreground: AppColors.textPrimary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _rowPillButton(
                    label: '공유하기',
                    background: _shareButtonBg,
                    foreground: AppColors.textPrimary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowPillButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(_buttonRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: _pillHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.0,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
