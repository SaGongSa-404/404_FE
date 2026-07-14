import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 웹에서 앱을 폰처럼 중앙에 고정하고, 화면에는 비율을 유지한 채 축소해 보여주는 프레임.
///
/// 이 앱은 폰 크기(설계폭 412)를 전제로, 일부 화면은 `MediaQuery.width/412` 스케일을,
/// 일부(로그인 등)는 고정 픽셀을 쓴다. 따라서 논리 크기를 412보다 좁히면 고정 크기 요소가
/// 상대적으로 커져 레이아웃이 깨진다.
///
/// 그래서 여기서는:
/// 1. 앱을 **설계 논리 크기 [_designWidth] x [_designHeight]** 로 렌더하고(배율 1.0, 비율 정상),
/// 2. 그 결과를 [FittedBox]로 **[displayWidth] 폭에 맞게 통째로 축소**해 화면에 표시한다.
///
/// - 세로 표시 높이는 폰 비율(설계 종횡비)로 자동 계산되며, 창이 더 낮으면 창에 맞춰 더 축소한다.
/// - 네이티브(모바일)에서는 아무 것도 하지 않는다(`kIsWeb` 가드).
/// - 웹이라도 창 폭이 [displayWidth] 이하면(모바일 브라우저 등) 그대로 통과시킨다.
class WebFrame extends StatelessWidget {
  const WebFrame({
    super.key,
    required this.child,
    this.displayWidth = 290, // 화면에 보이는 폭(비율 유지 축소). 높이는 자동(~645)
  });

  final Widget child;

  /// 화면에 표시될 폰 프레임의 가로 크기(px). 내부는 [_designWidth]로 렌더 후 이 폭으로 축소.
  final double displayWidth;

  /// 앱이 설계된 논리 크기(폰). 렌더는 항상 이 크기로 하고 화면엔 축소해 보여준다.
  static const double _designWidth = 412; // = kFigmaDesignWidth (배율 1.0)
  static const double _designHeight = 915; // 폰 비율(412 x 915)

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final media = MediaQuery.of(context);
    if (media.size.width <= displayWidth) return child;

    final scale = displayWidth / _designWidth;
    var displayHeight = _designHeight * scale;
    // 창이 표시 높이보다 낮으면 창 높이에 맞춰 더 축소(넘침 방지). FittedBox가 비율 유지.
    if (displayHeight > media.size.height) {
      displayHeight = media.size.height;
    }

    return ColoredBox(
      // 폰 프레임 바깥 배경.
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
              width: displayWidth,
              height: displayHeight,
              // 설계 크기(412x915)로 렌더한 앱을 표시 크기에 맞게 비율 유지 축소.
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _designWidth,
                  height: _designHeight,
                  child: MediaQuery(
                    // 하위 화면은 자신이 폰(412x915)에 있다고 인식 → 스케일·레이아웃 정상.
                    data: media.copyWith(
                      size: const Size(_designWidth, _designHeight),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
