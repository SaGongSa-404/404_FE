import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/shared/widgets/alarm/alarm_button.dart';
import 'package:flutter/material.dart';

/// 홈·마이페이지 상단 헤더 (Figma 412 기준, 높이 126).
class MainTabHeader extends StatelessWidget {
  const MainTabHeader({
    super.key,
    required this.leading,
    required this.onAlarmPressed,
    this.backgroundColor,
  });

  final Widget leading;
  final VoidCallback onAlarmPressed;
  final Color? backgroundColor;

  /// 위시탭 `개의 위시리스트` 제목과 동일 (Figma 20 / w600).
  static TextStyle titleTextStyle(double scale) => TextStyle(
        fontSize: 20 * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static const TextHeightBehavior titleTextHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  /// 위시탭 헤더 타이틀 행 높이 (Figma 40).
  static double titleRowHeight(double scale) => 40 * scale;

  static Widget tabTitle(String text, double scale) {
    return Text(
      text,
      style: titleTextStyle(scale),
      textHeightBehavior: titleTextHeightBehavior,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Container(
      height: 126 * scale,
      width: double.infinity,
      color: backgroundColor,
      padding: EdgeInsets.only(
        left: 30 * scale,
        right: 30 * scale,
        bottom: 16 * scale,
      ),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: titleRowHeight(scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: leading,
            ),
          ),
          AlarmButton(onPressed: onAlarmPressed),
        ],
      ),
    );
  }
}
