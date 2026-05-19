import 'package:fe_app/core/theme/app_theme.dart';
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
      final bottomPad = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 12),
        child: child,
      );
    },
  );
}

/// 모달·패널 공통 pill 버튼 (눌림 배경색 지정).
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
    final radius = BorderRadius.circular(widget.borderRadius);
    final bg = _pressed ? widget.pressedBackground : widget.background;

    final content = Padding(
      padding: widget.padding,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        height: widget.fixedHeight,
        child: Align(
          alignment: widget.alignLeft ? Alignment.centerLeft : Alignment.center,
          child: Transform.translate(
            offset: const Offset(0, 1.5),
            child: Text(
              widget.label,
              textAlign: widget.alignLeft ? TextAlign.left : TextAlign.center,
              strutStyle: StrutStyle(
                fontSize: widget.fontSize,
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
                fontSize: widget.fontSize,
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
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}
