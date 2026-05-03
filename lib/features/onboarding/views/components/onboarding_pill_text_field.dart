import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingPillTextField extends StatelessWidget {
  const OnboardingPillTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.hintFontSize = 18,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.done,
    this.hasError = false,
    this.trailing,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final double hintFontSize;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final bool hasError;
  final Widget? trailing;

  static const _textColor = Color(0xFF555555);
  static const _hintColor = Color(0xFF7B7B7B);
  static const _errorColor = Color(0xFFB26D6D);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 81,
      padding: EdgeInsets.symmetric(horizontal: hasError ? 30 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(hasError ? 52 : 100),
        border: hasError ? Border.all(color: _errorColor, width: 1) : null,
        boxShadow: hasError
            ? null
            : const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 3,
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: _textColor,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textInputAction: textInputAction,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _textColor,
                height: 1.548,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: hintFontSize,
                  fontWeight: FontWeight.w500,
                  color: _hintColor,
                  height: 1.548,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
