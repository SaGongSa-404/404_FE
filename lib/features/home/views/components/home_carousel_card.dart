import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class HomeCarouselCard extends StatelessWidget {
  const HomeCarouselCard({
    super.key,
    required this.child,
    required this.pageIndex,
    required this.currentPage,
    required this.pageCount,
  });

  static const double designWidth = 368;
  static const double designHeight = 200;
  static const double pageGap = 6;
  static const double activePageMargin = 20;

  static double get pageSlotWidth =>
      designWidth + pageGap + activePageMargin;
  static const double paddingHorizontal = 24;
  static const double paddingVertical = 28;

  final Widget child;
  final int pageIndex;
  final int currentPage;
  final int pageCount;

  static const Color _cardShadowColor = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Container(
      width: designWidth * scale,
      height: designHeight * scale,
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal * scale,
        vertical: paddingVertical * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: const [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            height: (designHeight - paddingVertical * 2) * scale,
            child: child,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(pageCount, (index) {
                final isActive = index == currentPage;
                return Container(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 9 * scale),
                  width: (isActive ? 22 : 10) * scale,
                  height: 7 * scale,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFCACACA)
                        : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
