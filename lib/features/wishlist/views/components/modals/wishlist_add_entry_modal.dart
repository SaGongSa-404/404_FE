import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/wishlist/views/components/modals/wishlist_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showWishlistAddEntryModal(
  BuildContext context, {
  required VoidCallback onPasteUrl,
  required VoidCallback onManualInput,
  required VoidCallback onLearnHow,
}) {
  return showWishlistModalBottomSheet(
    context,
    child: _WishlistAddEntryModalPanel(
      onPasteUrl: () {
        Navigator.of(context).pop();
        onPasteUrl();
      },
      onManualInput: () {
        Navigator.of(context).pop();
        onManualInput();
      },
      onLearnHow: () {
        Navigator.of(context).pop();
        onLearnHow();
      },
    ),
  );
}

class _WishlistAddEntryModalPanel extends StatefulWidget {
  const _WishlistAddEntryModalPanel({
    required this.onPasteUrl,
    required this.onManualInput,
    required this.onLearnHow,
  });

  final VoidCallback onPasteUrl;
  final VoidCallback onManualInput;
  final VoidCallback onLearnHow;

  @override
  State<_WishlistAddEntryModalPanel> createState() => _WishlistAddEntryModalPanelState();
}

class _WishlistAddEntryModalPanelState extends State<_WishlistAddEntryModalPanel> {
  static const Color _radiusBorder = Color(0xFFE0E0E0);
  static const Color _urlButtonBg = Color(0xFFEBF5FB);
  static const Color _urlButtonBorder = Color(0xFFD1E3F0);
  static const Color _urlButtonPressedBg = Color(0xFFDCEEF8);
  static const double _radius = 22;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 37,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24 * scale,
          31 * scale,
          24 * scale,
          31 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '링크 붙여넣기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20 * scale,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7 * scale),
            Text(
              '붙여넣으면 자동으로 정보를 불러와요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16 * scale,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 19 * scale),
            _pillButton(
              scale: scale,
              label: 'URL을 붙여넣으세요',
              onTap: widget.onPasteUrl,
              backgroundColor: _urlButtonBg,
              pressedBackgroundColor: _urlButtonPressedBg,
              borderColor: _urlButtonBorder,
              borderWidth: 1,
              textColor: AppColors.textSecondary,
              alignLeft: true,
            ),
            SizedBox(height: 12 * scale),
            _pillButton(
              scale: scale,
              label: '직접 입력하기',
              onTap: widget.onManualInput,
              backgroundColor: AppColors.white,
              pressedBackgroundColor: AppColors.grey_e6,
              borderColor: _radiusBorder,
              borderWidth: 1,
              textColor: AppColors.textPrimary,
              fontSize: 16,
              fixedHeight: 41,
            ),
            SizedBox(height: 12 * scale),
            Center(
              child: GestureDetector(
                onTap: widget.onLearnHow,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 4 * scale,
                    horizontal: 8 * scale,
                  ),
                  child: Text(
                    '담는 방법 보러가기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      height: 1.0,
                      color: AppColors.skyBlue_300,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.skyBlue_300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillButton({
    required double scale,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color pressedBackgroundColor,
    required Color borderColor,
    double borderWidth = 1,
    required Color textColor,
    bool alignLeft = false,
    bool useFullWidth = true,
    double fontSize = 18,
    double? fixedHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _AddEntryPillButton(
      scale: scale,
      label: label,
      onTap: onTap,
      backgroundColor: backgroundColor,
      pressedBackgroundColor: pressedBackgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      textColor: textColor,
      alignLeft: alignLeft,
      useFullWidth: useFullWidth,
      fontSize: fontSize,
      fixedHeight: fixedHeight,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
    );
  }
}

class _AddEntryPillButton extends StatefulWidget {
  const _AddEntryPillButton({
    required this.scale,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.textColor,
    required this.alignLeft,
    required this.useFullWidth,
    required this.fontSize,
    this.fixedHeight,
    required this.contentPadding,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color textColor;
  final bool alignLeft;
  final bool useFullWidth;
  final double fontSize;
  final double? fixedHeight;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<_AddEntryPillButton> createState() => _AddEntryPillButtonState();
}

class _AddEntryPillButtonState extends State<_AddEntryPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = _pressed ? widget.pressedBackgroundColor : widget.backgroundColor;
    final scale = widget.scale;

    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(999 * scale),
      child: InkWell(
        borderRadius: BorderRadius.circular(999 * scale),
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Ink(
          width: widget.useFullWidth ? double.infinity : null,
          height: widget.fixedHeight != null ? widget.fixedHeight! * scale : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999 * scale),
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth * scale,
            ),
          ),
          padding: widget.fixedHeight != null
              ? EdgeInsets.symmetric(horizontal: 20 * scale)
              : widget.contentPadding,
          child: Align(
            alignment: widget.alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Transform.translate(
              offset: Offset(0, 1.5 * scale),
              child: Text(
                widget.label,
                strutStyle: StrutStyle(
                  fontSize: widget.fontSize * scale,
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
                  fontWeight: FontWeight.w500,
                  fontSize: widget.fontSize * scale,
                  height: 1.0,
                  color: widget.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.useFullWidth) return button;
    return IntrinsicWidth(child: button);
  }
}
