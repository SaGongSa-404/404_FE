import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showWishlistItemActionModal(
  BuildContext context, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  assert(
    onEdit != null || onDelete != null,
    'onEdit 또는 onDelete 중 하나는 필요합니다.',
  );

  return showWishlistModalBottomSheet(
    context,
    child: _WishlistItemActionModalPanel(
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}

enum _ActionModalPage { menu, confirmDelete }

class _WishlistItemActionModalPanel extends StatefulWidget {
  const _WishlistItemActionModalPanel({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_WishlistItemActionModalPanel> createState() => _WishlistItemActionModalPanelState();
}

class _WishlistItemActionModalPanelState extends State<_WishlistItemActionModalPanel> {
  _ActionModalPage _page = _ActionModalPage.menu;

  static const Color _deleteMenuButtonBg = AppColors.grey;
  static const Color _cancelButtonBg = AppColors.grey;
  static const Color _confirmDeleteButtonBg = Color(0xFFD46868);

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _page == _ActionModalPage.menu ? _buildMenuPage(scale) : _buildConfirmDeletePage(scale),
        ),
      ),
    );
  }

  Widget _buildMenuPage(double scale) {
    return Column(
      key: const ValueKey<String>('menu'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onEdit != null)
          WishlistModalPillButton(
            label: '수정하기',
            background: AppColors.skyBlue_100,
            pressedBackground: AppColors.skyBlue_200,
            padding: const EdgeInsets.all(18),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEdit!();
            },
          ),
        if (widget.onEdit != null && widget.onDelete != null) SizedBox(height: 12 * scale),
        if (widget.onDelete != null)
          WishlistModalPillButton(
            label: '삭제하기',
            background: _deleteMenuButtonBg,
            pressedBackground: AppColors.grey_e6,
            padding: const EdgeInsets.all(18),
            onPressed: () => setState(() => _page = _ActionModalPage.confirmDelete),
          ),
      ],
    );
  }

  Widget _buildConfirmDeletePage(double scale) {
    return Column(
      key: const ValueKey<String>('confirm'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위시리스트에서\n정말 삭제하실 건가요?',
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
          '한 번 삭제된 위시리스트는 되돌릴 수 없어요',
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
                label: '삭제하기',
                background: _confirmDeleteButtonBg,
                pressedBackground: AppColors.red_500,
                foreground: AppColors.white,
                padding: const EdgeInsets.all(18),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete?.call();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
