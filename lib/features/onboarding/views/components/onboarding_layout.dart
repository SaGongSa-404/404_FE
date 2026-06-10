import 'package:flutter/material.dart';

/// 온보딩 화면 공통 레이아웃 상수.
abstract final class OnboardingLayout {
  static const designWidth = 412.0;
  static const topSpacerFlex = 65;
  static const backIconSize = 18.0;
  static const backSlotSize = 24.0;

  /// [OnboardingSpacedScrollView] 상단 여백. 모든 온보딩 화면에서 동일하게 사용.
  static Widget topSpacer() => Spacer(flex: topSpacerFlex);
}
