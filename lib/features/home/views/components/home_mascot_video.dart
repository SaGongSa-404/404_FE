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
  static const Map<String, double> _horizontalCropWidthFactors = {
    'nugul_home': 0.88,
    'nugul_just_smile': 0.88,
    'nugul_more_excited': 0.88,
  };
  static const Map<String, double> _downwardOffsets = {
    'nugul_home': 60,
    'nugul_just_smile': 60,
    'nugul_more_excited': 60,
  };

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

  double _horizontalCropWidthFactorFor(String? baseName) {
    if (baseName == null) return 1.0;
    return _horizontalCropWidthFactors[baseName] ?? 1.0;
  }

  double _downwardOffsetFor(String? baseName) {
    if (baseName == null) return _zoomDownwardOffset;
    return _downwardOffsets[baseName] ?? _zoomDownwardOffset;
  }

  Widget _buildVideoFrame(
    Size videoSize,
    Widget player,
    double horizontalCropWidthFactor,
  ) {
    final frame = SizedBox(
      width: videoSize.width,
      height: videoSize.height,
      child: player,
    );

    if (horizontalCropWidthFactor == 1.0) return frame;

    // 에셋 내부의 좌우 빈 여백만 잘라내고 기존 전체 확대값은 그대로 유지한다.
    return ClipRect(
      child: Align(
        alignment: Alignment.center,
        widthFactor: horizontalCropWidthFactor,
        child: frame,
      ),
    );
  }

  Widget _wrapZoom(
    BuildContext context,
    Widget child,
    double zoom,
    double downwardOffset,
  ) {
    if (zoom == 1.0) return child;
    final scale = responsiveScale(context);
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, downwardOffset * scale),
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
    final baseName = _resolvedBaseName();
    final zoom = _zoomScaleFor(baseName);
    final horizontalCropWidthFactor = _horizontalCropWidthFactorFor(baseName);
    final downwardOffset = _downwardOffsetFor(baseName);
    final useNativeFraming = zoom == 1.0 && !_isReferenceSize(videoSize);
    final videoFrame = _buildVideoFrame(
      videoSize,
      player,
      horizontalCropWidthFactor,
    );

    Widget content;

    // 홈 기본 영상(1044×1864)은 한 번만 스케일 — 이중 FittedBox 시 선명도가 떨어짐
    if (_isReferenceSize(videoSize)) {
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: videoFrame,
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
              child: videoFrame,
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
          child: videoFrame,
        ),
      );
    }

    return _wrapZoom(context, content, zoom, downwardOffset);
  }
}
