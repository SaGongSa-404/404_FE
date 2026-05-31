import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:fe_app/features/wishlist/views/components/item/wishlist_upload_share_icon.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_item_action_modal.dart';
import 'package:flutter/material.dart';

class WishlistItemCard extends StatefulWidget {
  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  final WishlistPlaceholder item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard> {
  static const double _thumbSize = 81;
  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);
  static const double _cardShadowBlur = 4;
  static const double _cardShadowSpread = 0;
  static const Color _cardPressedBackground = Color(0xFFD2D2D2);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius * scale),
        boxShadow: [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: _cardShadowBlur,
            spreadRadius: _cardShadowSpread,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius * scale),
        clipBehavior: Clip.antiAlias,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            color: _pressed ? _cardPressedBackground : AppColors.white,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          14 * scale,
                          16 * scale,
                          14 * scale,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _thumbnail(scale),
                            SizedBox(width: 20 * scale),
                            Expanded(child: _titleAndPrice(scale)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 6 * scale,
                        top: 8 * scale,
                        bottom: 8 * scale,
                      ),
                      child: _actionIcons(context, scale),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(double scale) {
    final url = widget.item.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10 * scale),
        child: Image.network(
          url,
          width: _thumbSize * scale,
          height: _thumbSize * scale,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbnailPlaceholder(scale),
        ),
      );
    }
    return _thumbnailPlaceholder(scale);
  }

  Widget _thumbnailPlaceholder(double scale) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10 * scale),
      child: Container(
        width: _thumbSize * scale,
        height: _thumbSize * scale,
        alignment: Alignment.center,
        color: const Color(0xFFE8E8E8),
        child: Icon(
          Icons.photo_camera,
          size: 45 * scale,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _titleAndPrice(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          '${_formatPrice(widget.item.price)}원',
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _actionIcons(BuildContext context, double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.onEdit != null || widget.onDelete != null)
          Tooltip(
            message: '더보기',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showWishlistItemActionModal(
                  context,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40 * scale,
                  height: 40 * scale,
                  child: Icon(
                    Icons.more_vert,
                    size: 22 * scale,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: Icon(
              Icons.more_vert,
              size: 22 * scale,
              color: AppColors.brown,
            ),
          ),
        Tooltip(
          message: '공유',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onShare,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 40 * scale,
                height: 40 * scale,
                child: Center(
                  child: WishlistUploadShareIcon(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatPrice(int value) {
  final chars = value.toString().split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) buffer.write(',');
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}
