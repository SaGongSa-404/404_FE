import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// pill 형태 버튼의 눌림 색상 전환. `option_modal` 수정/삭제 버튼과 동일한 패턴입니다.
class PressPillButton extends StatefulWidget {
  const PressPillButton({
    super.key,
    required this.defaultColor,
    required this.pressedColor,
    required this.child,
    this.onTap,
    this.height,
    this.borderRadius = 57,
  });

  static const Color blueDefault = AppColors.skyBlue_100;
  static const Color bluePressed = AppColors.skyBlue_200;
  static const Color greyDefault = AppColors.grey_100;
  static const Color greyPressed = AppColors.grey_300;

  final Color defaultColor;
  final Color pressedColor;
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final double borderRadius;

  @override
  State<PressPillButton> createState() => _PressPillButtonState();
}

class _PressPillButtonState extends State<PressPillButton> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _interactive ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _interactive
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: _interactive ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        decoration: BoxDecoration(
          color: _pressed && _interactive
              ? widget.pressedColor
              : widget.defaultColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
