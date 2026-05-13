import 'package:flutter/material.dart';

abstract class AppColors {
  // 로그인 관련 색상
  static const kakao = Color(0xFFFFDB82);
  static const kakao_clicked = Color(0xFFDBB146);
  static const google = Color(0xFFFFFFFF);
  static const google_clicked = Color(0xFFCACACA);

  static const background = Color(0xFFF1F1F1);
  static const textPrimary = Color(0xFF555555);
  static const textSecondary = Color(0xFF7B7B7B);
  static const textDark = Color(0xFF333333);
  static const textDate = Color(0xFF969696);

  static const red_100 = Color(0xFFE8C1C1);
  static const red_200 = Color(0xFFD6A5A5);
  static const red_300 = Color(0xFFC48989);
  static const red_400 = Color(0xFFB26D6D);
  static const red_500 = Color(0xFFA05151);
  static const red_600 = Color(0xFFD46868);

  static const yellow = Color(0xFFF7E1AA);

  static const skyBlue_000_clicked = Color(0xFFE8F3F9); // option clicked
  static const skyBlue_100 = Color(0xFFC1D8E8);
  static const skyBlue_200 = Color(0xFF89ADC4);
  static const skyBlue_300 = Color(0xFF6D96B2);

  static const grey = Color(0xFFF1F1F1);
  static const white = Color(0xFFFFFFFF);
  static const brown = Color(0xFF70534F);

  static const greyButton = Color(0xFFECECEC);
  static const yellowLight = Color(0xFFFFF8E8);
  static const toastBlue = Color.fromRGBO(95, 142, 174, 1);
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
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.textPrimary,
  );
}