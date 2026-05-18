import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReflectCompleteButton extends StatefulWidget {
  const ReflectCompleteButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  static const Color _bg = Color(0xFFC7D9E5);
  static const Color _bgPressed = Color(0xFF89ADC4);
  static const Color _bgDisabled = Color(0xFFE0E8EE);

  @override
  State<ReflectCompleteButton> createState() => _ReflectCompleteButtonState();
}

class _ReflectCompleteButtonState extends State<ReflectCompleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    final bg = !widget.enabled
        ? ReflectCompleteButton._bgDisabled
        : _pressed
            ? ReflectCompleteButton._bgPressed
            : ReflectCompleteButton._bg;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.enabled ? widget.onPressed : null,
          onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                '완료하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
