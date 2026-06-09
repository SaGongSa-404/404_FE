import 'package:flutter/material.dart';

/// 약관·정책 본문이 가로 폭을 넘어 레이아웃이 깨지지 않도록 감싸는 텍스트 위젯.
class LegalBodyText extends StatelessWidget {
  const LegalBodyText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: style,
        softWrap: true,
      ),
    );
  }
}

class LegalRichBodyText extends StatelessWidget {
  const LegalRichBodyText({
    super.key,
    required this.children,
    required this.baseStyle,
  });

  final List<InlineSpan> children;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(style: baseStyle, children: children),
        softWrap: true,
      ),
    );
  }
}

TextSpan legalBoldSpan(String text, TextStyle baseStyle) {
  return TextSpan(
    text: text,
    style: baseStyle.copyWith(fontWeight: FontWeight.w600),
  );
}

TextSpan legalPlainSpan(String text) => TextSpan(text: text);
