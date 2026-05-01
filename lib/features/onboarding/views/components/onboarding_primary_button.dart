import 'package:flutter/material.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  static const _enabledColor = Color(0xFFC1DBE8);
  static const _disabledColor = Color(0xFFD2D2D2);
  static const _textColor = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final borderRadius = BorderRadius.circular(75);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled ? _enabledColor : _disabledColor,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
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
