import 'package:fe_app/core/theme/app_theme.dart';
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
  static const double _radius = 22;

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
        padding: const EdgeInsets.fromLTRB(24, 31, 24, 31),
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
                  child: WishlistModalPillButton(
                    label: '취소',
                    background: _cancelButtonBg,
                    pressedBackground: AppColors.grey_e6,
                    padding: const EdgeInsets.all(18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
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
