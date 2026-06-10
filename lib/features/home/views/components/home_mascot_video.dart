import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/core/utils/video_asset.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeMascotVideo extends StatelessWidget {
  const HomeMascotVideo({
    super.key,
    required this.controller,
    this.videoBaseName,
  });

  static const Size referenceSize = Size(1044, 1864);

  static const Set<String> _nativeFramingBaseNames = {
    'nugul_rainy',
    'nugul_budget_left_0',
  };

  static const double _zoomScale = 1.11;
  static const double _zoomDownwardOffset = 40;

  final VideoPlayerController controller;
  final String? videoBaseName;

  bool _isReferenceSize(Size videoSize) {
    return (videoSize.width - referenceSize.width).abs() < 1 &&
        (videoSize.height - referenceSize.height).abs() < 1;
  }

  String? _resolvedBaseName() {
    return videoBaseName ?? videoBaseNameFromDataSource(controller.dataSource);
  }

  double _zoomScaleFor(String? baseName) {
    if (baseName == null || _nativeFramingBaseNames.contains(baseName)) {
      return 1.0;
    }
    if (baseName.startsWith('nugul_')) {
      return _zoomScale;
    }
    return 1.0;
  }

  Widget _wrapZoom(BuildContext context, Widget child, double zoom) {
    if (zoom == 1.0) return child;
    final scale = responsiveScale(context);
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, _zoomDownwardOffset * scale),
        child: Transform.scale(
          scale: zoom,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const SizedBox.expand();
    }

    final player = VideoPlayer(controller);
    final zoom = _zoomScaleFor(_resolvedBaseName());
    final useNativeFraming = zoom == 1.0 && !_isReferenceSize(videoSize);

    Widget content;

    // 홈 기본 영상(1044×1864)은 한 번만 스케일 — 이중 FittedBox 시 선명도가 떨어짐
    if (_isReferenceSize(videoSize)) {
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: player,
          ),
        ),
      );
    } else if (useNativeFraming) {
      // rainy·budget_left_0: 720×1280 기준 캔버스 정규화만
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: referenceSize.width,
            height: referenceSize.height,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: videoSize.width,
                height: videoSize.height,
                child: player,
              ),
            ),
          ),
        ),
      );
    } else {
      // just_smile·more_excited 등: 기준 캔버스 없이 화면에 맞춘 뒤 확대
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: player,
          ),
        ),
      );
    }

    return _wrapZoom(context, content, zoom);
  }
}
