import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/models/wishlist_placeholder.dart';
import 'package:flutter/material.dart';

class ReflectItemCard extends StatelessWidget {
  const ReflectItemCard({
    super.key,
    required this.item,
    required this.purchasedAtLabel,
  });

  final WishlistPlaceholder item;
  final String purchasedAtLabel;

  static const double _thumbSize = 81;
  static const double _thumbRadius = 12;
  static const double _cardRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);
  static const Color _badgeBg = Color(0xFFFFF3D7);
  static const Color _badgeText = Color(0xFFD19A13);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius * scale),
        boxShadow: const [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
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
            SizedBox(width: 17 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    '${_formatPrice(item.price)}원',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 21 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          purchasedAtLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      _boughtBadge(scale),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boughtBadge(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: _badgeBg,
        borderRadius: BorderRadius.circular(999 * scale),
      ),
      child: Text(
        '샀어요',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15 * scale,
          fontWeight: FontWeight.w500,
          color: _badgeText,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _thumbnail(double scale) {
    final url = item.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_thumbRadius * scale),
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
      borderRadius: BorderRadius.circular(_thumbRadius * scale),
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
