import 'package:flutter/material.dart';

// 사용 예시
// Text('환영합니다', style: AppTextStyles.welcome),

// 색상 바꾸고 싶을 때 copyWith으로
// Text('부제목', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),

abstract class AppColors {
  static const skyBlue = Color(0xFFC1DBE8);
  static const skyBlue_clicked = Color(0xFF89ADC4);
  static const background = Color(0xFFF1F1F1);
  static const option_clicked = Color(0xFFE8F3F9);

  // 로그인 관련 색상
  static const kakao = Color(0xFFFFDB82);
  static const kakao_clicked = Color(0xFFDBB146);
  static const google = Color(0xFFFFFFFF);
  static const google_clicked = Color(0xFFCACACA);

  static const textPrimary = Color(0xFF555555);
  static const textSecondary = Color(0xFF7B7B7B);
  static const error_moneyOver = Color(0xFFB26D6D);

}

abstract class AppTextStyles {
  static const wezkzklcome = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: AppColors.textPrimary,
  );

  static const heading = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    fontSize: 25,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const buttonContent = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 18,
    color: AppColors.textPrimary,
  );
}