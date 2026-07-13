import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 웹에서 앱을 폰 폭으로 중앙 정렬하는 전역 프레임.
///
/// 이 앱의 UI는 `MediaQuery.width / 412`(피그마 기준폭)로 스케일한다.
/// 넓은 데스크톱 브라우저에선 이 값이 커져 UI가 거대하게 늘어나므로,
/// 웹에서 창이 [maxContentWidth]보다 넓을 때 콘텐츠를 해당 폭으로 캡·중앙정렬하고
/// **MediaQuery의 size.width도 함께 덮어써** 하위 화면들의 스케일이 폰 크기로 유지되게 한다.
///
/// - 네이티브(모바일)에서는 아무 것도 하지 않는다(`kIsWeb` 가드).
/// - 웹이라도 창이 [maxContentWidth] 이하면(모바일 브라우저 등) 그대로 통과시킨다.
class WebFrame extends StatelessWidget {
  const WebFrame({
    super.key,
    required this.child,
    this.maxContentWidth = 480,
  });

  final Widget child;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final media = MediaQuery.of(context);
    if (media.size.width <= maxContentWidth) return child;

    return ColoredBox(
      // 폰 프레임 양옆 배경 (앱 배경 #F1F1F1보다 약간 어둡게).
      color: const Color(0xFFE2E2E2),
      child: Center(
        child: ClipRect(
          child: SizedBox(
            width: maxContentWidth,
            child: MediaQuery(
              // 하위 화면의 MediaQuery.width/sizeOf가 폰 폭을 보게 한다.
              data: media.copyWith(
                size: Size(maxContentWidth, media.size.height),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
