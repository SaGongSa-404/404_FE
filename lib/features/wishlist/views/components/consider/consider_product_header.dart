import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class ConsiderProductHeader extends StatelessWidget {
  const ConsiderProductHeader({
    super.key,
    this.title = 'PWC RIBBED EVERYDAY\nSHORT SLEEVE TEE',
    this.price = 29000,
    this.category = '패션',
    this.imageUrl,
  });

  final String title;
  final int price;
  final String category;
  final String? imageUrl;

  static const double _cardBorderRadius = 22;
  static const Color _cardShadowColor = Color(0x22000000);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius * scale),
        boxShadow: const [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius * scale),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductImage(
              imageUrl: imageUrl,
              height: 150 * scale,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15 * scale, 15 * scale, 15 * scale, 15 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      _CategoryTag(label: category, scale: scale),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    '${_formatPrice(price)}원',
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.height,
  });

  final String? imageUrl;
  final double height;

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
              errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
            )
          : const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return ColoredBox(
      color: const Color(0xFFF2F2F2),
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

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.label,
    required this.scale,
  });

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Color(0xFFAEAEAE)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
