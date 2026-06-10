import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class FeedProductCard extends StatelessWidget {
  const FeedProductCard({
    super.key,
    required this.name,
    this.price,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final int? price;
  final String? imageUrl;
  final VoidCallback? onTap;

  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);
  static const Color _imagePlaceholderColor = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final borderRadius = _cardBorderRadius * scale;
    final imageHeight = 150 * scale;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductImage(
              imageUrl: imageUrl,
              height: imageHeight,
              scale: scale,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                15 * scale,
                15 * scale,
                15 * scale,
                15 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  if (price != null) ...[
                    SizedBox(height: 8 * scale),
                    Text(
                      '${_formatKrw(price!)}원',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 15 * scale,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  static String _formatKrw(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.height,
    required this.scale,
  });

  final String? imageUrl;
  final double height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ImagePlaceholder(scale: scale),
            )
          : _ImagePlaceholder(scale: scale),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FeedProductCard._imagePlaceholderColor,
      child: Center(
        child: Icon(
          Icons.photo_camera,
          size: 45 * scale,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
