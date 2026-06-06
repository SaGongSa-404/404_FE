import 'package:flutter/material.dart';
import 'package:fe_app/core/theme/app_theme.dart';

class OnboardingPrimaryButton extends StatefulWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback? onPressed;
  final double fontSize;

  @override
  State<OnboardingPrimaryButton> createState() =>
      _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(75);
    final isEnabled = widget.onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isEnabled
            ? (_pressed ? AppColors.skyBlue_200 : AppColors.skyBlue_100)
            : AppColors.buttonDisabledBg,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: isEnabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: isEnabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: isEnabled ? () => setState(() => _pressed = false) : null,
          borderRadius: borderRadius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.buttonDisabledText,
                  height: 1.548,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
