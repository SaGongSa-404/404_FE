import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 웹에서 앱을 폰 크기(가로·세로)로 중앙 고정하는 전역 프레임.
///
/// 이 앱의 UI는 `MediaQuery.width / 412`(피그마 기준폭)로 스케일한다.
/// 넓은 데스크톱 브라우저에선 이 값이 커져 UI가 거대하게 늘어나므로,
/// 웹에서 창이 [maxContentWidth]보다 넓을 때 콘텐츠를 폰 크기로 캡·중앙정렬하고
/// **MediaQuery의 size(width·height)도 함께 덮어써** 하위 화면들의 스케일·레이아웃이
/// 폰 크기로 유지되게 한다.
///
/// - 가로: [maxContentWidth]로 고정.
/// - 세로: [maxContentHeight]로 고정하되, 창이 그보다 낮으면 창 높이에 맞춘다(넘침 방지).
/// - 네이티브(모바일)에서는 아무 것도 하지 않는다(`kIsWeb` 가드).
/// - 웹이라도 창이 [maxContentWidth] 이하면(모바일 브라우저 등) 그대로 통과시킨다.
class WebFrame extends StatelessWidget {
  const WebFrame({
    super.key,
    required this.child,
    this.maxContentWidth = 480,
    this.maxContentHeight = 915,
  });

  final Widget child;
  final double maxContentWidth;
  final double maxContentHeight;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final media = MediaQuery.of(context);
    if (media.size.width <= maxContentWidth) return child;

    // 세로는 폰 높이로 고정하되, 창이 더 낮으면 창 높이에 맞춰 넘침을 막는다.
    final frameHeight = media.size.height < maxContentHeight
        ? media.size.height
        : maxContentHeight;

    return ColoredBox(
      // 폰 프레임 양옆·위아래 배경.
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: DecoratedBox(
          // 흰 배경 위에서 폰 프레임이 구분되도록 옅은 그림자.
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 24,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRect(
            child: SizedBox(
              width: maxContentWidth,
              height: frameHeight,
              child: MediaQuery(
                // 하위 화면의 MediaQuery.size가 폰 크기를 보게 한다.
                data: media.copyWith(
                  size: Size(maxContentWidth, frameHeight),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
