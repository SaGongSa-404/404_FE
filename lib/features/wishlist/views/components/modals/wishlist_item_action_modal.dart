import 'package:fe_app/core/theme/app_theme.dart';
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

  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x59000000),
    builder: (dialogContext) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(24, 23, 24, 23),
        child: _WishlistItemActionModalPanel(
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      );
    },
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

  static const Color _editButtonBg = AppColors.skyBlue_100;
  static const Color _deleteMenuButtonBg = AppColors.grey;
  static const Color _cancelButtonBg = AppColors.grey;
  static const Color _confirmDeleteButtonBg = Color(0xFFD46868);
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _page == _ActionModalPage.menu ? _buildMenuPage() : _buildConfirmDeletePage(),
        ),
      ),
    );
  }

  Widget _buildMenuPage() {
    return Column(
      key: const ValueKey<String>('menu'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onEdit != null)
          _stackedPillButton(
            label: '수정하기',
            background: _editButtonBg,
            foreground: AppColors.textPrimary,
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEdit!();
            },
          ),
        if (widget.onEdit != null && widget.onDelete != null) const SizedBox(height: 12),
        if (widget.onDelete != null)
          _stackedPillButton(
            label: '삭제하기',
            background: _deleteMenuButtonBg,
            foreground: AppColors.textPrimary,
            onPressed: () => setState(() => _page = _ActionModalPage.confirmDelete),
          ),
      ],
    );
  }

  Widget _buildConfirmDeletePage() {
    return Column(
      key: const ValueKey<String>('confirm'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '위시리스트에서\n정말 삭제하실 건가요?',
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
          '한 번 삭제된 위시리스트는 되돌릴 수 없어요',
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
                label: '삭제하기',
                background: _confirmDeleteButtonBg,
                foreground: AppColors.white,
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

  Widget _stackedPillButton({
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
          width: double.infinity,
          height: _pillHeight,
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
