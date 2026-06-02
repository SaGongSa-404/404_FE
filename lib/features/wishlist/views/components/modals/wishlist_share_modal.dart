import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showWishlistShareToFeedModal(
  BuildContext context, {
  VoidCallback? onConfirm,
}) {
  return showWishlistModalBottomSheet(
    context,
    child: _WishlistShareModalPanel(onConfirm: onConfirm),
  );
}

class _WishlistShareModalPanel extends StatelessWidget {
  const _WishlistShareModalPanel({this.onConfirm});

  final VoidCallback? onConfirm;

  static const Color _cancelButtonBg = AppColors.grey;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 37 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24 * scale, 31 * scale, 24 * scale, 31 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '피드에 공유하시겠습니까?',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20 * scale,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              '위시리스트를 공유하고 여러 사람들에게 조언을 구해보세요!',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16 * scale,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 27 * scale),
            Row(
              children: [
                Expanded(
                  child: WishlistModalPillButton(
                    label: '취소',
                    background: _cancelButtonBg,
                    pressedBackground: AppColors.grey_e6,
                    padding: const EdgeInsets.all(18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: WishlistModalPillButton(
                    label: '공유하기',
                    background: AppColors.skyBlue_100,
                    pressedBackground: AppColors.skyBlue_200,
                    padding: const EdgeInsets.all(18),
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
}
