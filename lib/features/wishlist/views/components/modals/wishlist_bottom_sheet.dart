import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

const Color wishlistSheetBarrierColor = Color(0x59000000);

Future<void> showWishlistModalBottomSheet(
  BuildContext context, {
  required Widget child,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: wishlistSheetBarrierColor,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    builder: (sheetContext) {
      final scale = responsiveScale(sheetContext);
      final bottomPad = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, bottomPad + 12 * scale),
        child: child,
      );
    },
  );
}

class WishlistModalPillButton extends StatefulWidget {
  const WishlistModalPillButton({
    super.key,
    required this.label,
    required this.background,
    required this.pressedBackground,
    required this.onPressed,
    this.foreground = AppColors.textPrimary,
    this.borderRadius = 999,
    this.padding = const EdgeInsets.all(15),
    this.fullWidth = true,
    this.fixedHeight,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
    this.alignLeft = false,
  });

  final String label;
  final Color background;
  final Color pressedBackground;
  final VoidCallback? onPressed;
  final Color foreground;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;
  final double? fixedHeight;
  final double fontSize;
  final FontWeight fontWeight;
  final bool alignLeft;

  @override
  State<WishlistModalPillButton> createState() => _WishlistModalPillButtonState();
}

class _WishlistModalPillButtonState extends State<WishlistModalPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final radius = BorderRadius.circular(widget.borderRadius * scale);
    final bg = _pressed ? widget.pressedBackground : widget.background;
    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
    final padding = EdgeInsets.fromLTRB(
      resolvedPadding.left * scale,
      resolvedPadding.top * scale,
      resolvedPadding.right * scale,
      resolvedPadding.bottom * scale,
    );
    final fontSize = widget.fontSize * scale;
    final fixedHeight = widget.fixedHeight != null ? widget.fixedHeight! * scale : null;

    final content = Padding(
      padding: padding,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        height: fixedHeight,
        child: Align(
          alignment: widget.alignLeft ? Alignment.centerLeft : Alignment.center,
          child: Transform.translate(
            offset: Offset(0, 1.5 * scale),
            child: Text(
              widget.label,
              textAlign: widget.alignLeft ? TextAlign.left : TextAlign.center,
              strutStyle: StrutStyle(
                fontSize: fontSize,
                height: 1.0,
                leading: 0,
                forceStrutHeight: true,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: widget.fontWeight,
                fontSize: fontSize,
                height: 1.0,
                color: widget.foreground,
              ),
            ),
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: widget.onPressed != null
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: widget.onPressed != null
              ? (_) => setState(() => _pressed = false)
              : null,
          onTapCancel:
              widget.onPressed != null ? () => setState(() => _pressed = false) : null,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}
