import 'package:flutter/material.dart';

// 사용 예시
// Text('환영합니다', style: AppTextStyles.welcome),

// 색상 바꾸고 싶을 때 copyWith으로
// Text('부제목', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),

abstract class AppColors {
  static const skyBlue = Color(0xFFC1DBE8);
  static const background = Color(0xFFF1F1F1);
  static const kakao = Color(0xFFFFDC69);
  static const textPrimary = Color(0xFF555555);
  static const textSecondary = Color(0xFF7B7B7B);
}

abstract class AppTextStyles {
  static const welcome = TextStyle(
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