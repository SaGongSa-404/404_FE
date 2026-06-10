import 'package:flutter/material.dart';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/shared/content/terms_content.dart';

class TermsDocumentView extends StatelessWidget {
  const TermsDocumentView({
    super.key,
    required this.sections,
    required this.scale,
    this.documentTitle,
    this.bottomSpacing,
    this.compact = false,
  });

  final List<TermsSection> sections;
  final double scale;
  final String? documentTitle;
  final double? bottomSpacing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bottom = bottomSpacing ?? 30 * scale;
    final bodyStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 13 * scale,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (documentTitle != null) ...[
          Text(
            documentTitle!,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16 * scale),
        ],
        for (var i = 0; i < sections.length; i++) ...[
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 && compact ? 0 : 18 * scale,
              bottom: 6 * scale,
            ),
            child: Text(
              sections[i].title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ..._buildSectionBody(
            section: sections[i],
            bodyStyle: bodyStyle,
            indentUnit: 16 * scale,
          ),
        ],
        SizedBox(height: bottom),
      ],
    );
  }

  List<Widget> _buildSectionBody({
    required TermsSection section,
    required TextStyle bodyStyle,
    required double indentUnit,
  }) {
    return [
      for (final paragraph in section.paragraphs)
        Text(paragraph, style: bodyStyle),
      for (final bullet in section.bullets)
        _buildBulletItem(
          bullet: bullet,
          bodyStyle: bodyStyle,
        ),
      for (final item in section.items)
        _buildListItem(
          item: item,
          bodyStyle: bodyStyle,
          indentUnit: indentUnit,
        ),
    ];
  }

  double get _markerGap => (4 * scale).clamp(3.0, 6.0);

  double get _bulletIndent => (8 * scale).clamp(6.0, 12.0);

  double get _bulletMarkerWidth => (10 * scale).clamp(8.0, 14.0);

  double get _numericPrefixWidth => (14 * scale).clamp(12.0, 18.0);

  double get _circledPrefixWidth => (18 * scale).clamp(14.0, 22.0);

  Widget _buildBulletItem({
    required TermsBulletItem bullet,
    required TextStyle bodyStyle,
  }) {
    final nestedIndent = _bulletIndent + _bulletMarkerWidth + _markerGap;
    final letterPrefixWidth = (14 * scale).clamp(12.0, 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: _bulletIndent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _bulletMarkerWidth,
                child: Text('•', style: bodyStyle),
              ),
              SizedBox(width: _markerGap),
              Expanded(
                child: Text(bullet.text, style: bodyStyle),
              ),
            ],
          ),
        ),
        for (var i = 0; i < bullet.children.length; i++)
          Padding(
            padding: EdgeInsets.only(left: nestedIndent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: letterPrefixWidth,
                  child: Text(
                    '${String.fromCharCode(97 + i)}.',
                    style: bodyStyle,
                  ),
                ),
                SizedBox(width: _markerGap),
                Expanded(
                  child: Text(
                    bullet.children[i],
                    style: _childTextStyle(bodyStyle, bullet.children[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  TextStyle _childTextStyle(TextStyle bodyStyle, String text) {
    if (!text.startsWith('이메일:')) return bodyStyle;

    return bodyStyle.copyWith(decoration: TextDecoration.underline);
  }

  static final _numericPrefixPattern = RegExp(r'^\d+\.$');

  Widget _buildListItem({
    required TermsListItem item,
    required TextStyle bodyStyle,
    required double indentUnit,
  }) {
    final content = item.label != null ? '${item.label}: ${item.text}' : item.text;
    final isNumericPrefix = _numericPrefixPattern.hasMatch(item.prefix);

    final prefixWidth =
        isNumericPrefix ? _numericPrefixWidth : _circledPrefixWidth;
    final leftPadding = item.indentLevel * indentUnit +
        (isNumericPrefix ? (4 * scale).clamp(3.0, 6.0) : 0.0);

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: prefixWidth,
            child: Text(item.prefix, style: bodyStyle),
          ),
          SizedBox(width: _markerGap),
          Expanded(
            child: Text(content, style: bodyStyle),
          ),
        ],
      ),
    );
  }
}
