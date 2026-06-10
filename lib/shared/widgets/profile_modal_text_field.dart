import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 프로필 모달 입력 필드 — 위시리스트 등록/수정 폼과 동일한 테두리·그림자
class ProfileModalTextField extends StatelessWidget {
  static const _fieldPillRadius = 30.0;
  static const _fieldHeight = 58.0;
  static const _fieldErrorBorder = Color(0xFF9C4444);
  static const _fieldShadowColor = Color(0x22000000);

  const ProfileModalTextField({
    super.key,
    required this.controller,
    required this.scale,
    this.hasError = false,
    this.hintText = '입력하기',
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.left,
  });

  final TextEditingController controller;
  final double scale;
  final bool hasError;
  final String hintText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _fieldHeight * scale,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_fieldPillRadius * scale),
        border: hasError
            ? Border.all(color: _fieldErrorBorder, width: 1 * scale)
            : null,
        boxShadow: hasError
            ? null
            : [
                BoxShadow(
                  color: _fieldShadowColor,
                  blurRadius: 4 * scale,
                ),
              ],
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
