import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleFontSize = 30,
    this.titleHeight = 1.548,
    this.gap = 22,
  });

  final String title;
  final String subtitle;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final double titleFontSize;
  final double titleHeight;
  final double gap;

  static const _color = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: _color,
            height: titleHeight,
          ),
        ),
        SizedBox(height: gap),
        Text(
          subtitle,
          textAlign: textAlign,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: _color,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
