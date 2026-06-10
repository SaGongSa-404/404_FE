import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 온보딩 화면용 스크롤 레이아웃.
///
/// [Spacer] flex 비율은 그대로 유지하되, 콘텐츠가 viewport를 넘으면
/// 여백을 0으로 줄여 overflow 없이 스크롤되게 합니다.
/// 여유 공간이 있을 때는 [IntrinsicHeight] + [Spacer]와 동일하게 배치됩니다.
class OnboardingSpacedScrollView extends StatelessWidget {
  const OnboardingSpacedScrollView({
    super.key,
    required this.viewportHeight,
    required this.children,
    this.keyboardDismissBehavior,
  });

  final double viewportHeight;
  final List<Widget> children;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  List<Widget> _buildColumnChildren(List<Widget> source) {
    return source
        .map(
          (child) => child is Spacer
              ? _OnboardingFlexGap(flex: child.flex)
              : child,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: viewportHeight),
        child: _OnboardingSpacedColumn(
          minHeight: viewportHeight,
          children: _buildColumnChildren(children),
        ),
      ),
    );
  }
}

class _OnboardingFlexGap extends LeafRenderObjectWidget {
  const _OnboardingFlexGap({required this.flex});

  final int flex;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOnboardingFlexGap(flex: flex);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderOnboardingFlexGap renderObject,
  ) {
    renderObject.flex = flex;
  }
}

class _RenderOnboardingFlexGap extends RenderBox {
  _RenderOnboardingFlexGap({required int flex}) : _flex = flex;

  int _flex;
  set flex(int value) {
    if (_flex == value) return;
    _flex = value;
    markNeedsLayout();
  }

  int get flex => _flex;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  double computeMinIntrinsicWidth(double width) => 0;

  @override
  double computeMaxIntrinsicWidth(double width) => 0;

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }
}

class _OnboardingSpacedColumn extends MultiChildRenderObjectWidget {
  const _OnboardingSpacedColumn({
    required this.minHeight,
    required super.children,
  });

  final double minHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOnboardingSpacedColumn(minHeight: minHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderOnboardingSpacedColumn renderObject,
  ) {
    renderObject.minHeight = minHeight;
  }
}

class _OnboardingSpacedColumnParentData
    extends ContainerBoxParentData<RenderBox> {}

class _RenderOnboardingSpacedColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OnboardingSpacedColumnParentData>,
        RenderBoxContainerDefaultsMixin<
            RenderBox, _OnboardingSpacedColumnParentData> {
  _RenderOnboardingSpacedColumn({required double minHeight})
      : _minHeight = minHeight;

  double _minHeight;
  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OnboardingSpacedColumnParentData) {
      child.parentData = _OnboardingSpacedColumnParentData();
    }
  }

  bool _isFlexGap(RenderBox child) => child is _RenderOnboardingFlexGap;

  int _flexFor(RenderBox child) {
    return (child as _RenderOnboardingFlexGap).flex;
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    var fixedHeight = 0.0;
    var totalFlex = 0;

    var child = firstChild;
    while (child != null) {
      if (_isFlexGap(child)) {
        totalFlex += _flexFor(child);
      } else {
        child.layout(BoxConstraints(maxWidth: width), parentUsesSize: true);
        fixedHeight += child.size.height;
      }
      child = (child.parentData! as _OnboardingSpacedColumnParentData)
          .nextSibling;
    }

    final flexSpace = fixedHeight >= _minHeight
        ? 0.0
        : _minHeight - fixedHeight;
    final columnHeight =
        fixedHeight + flexSpace < _minHeight ? _minHeight : fixedHeight + flexSpace;

    var offsetY = 0.0;
    child = firstChild;
    while (child != null) {
      final parentData =
          child.parentData! as _OnboardingSpacedColumnParentData;
      if (_isFlexGap(child)) {
        final gapHeight =
            totalFlex == 0 ? 0.0 : flexSpace * _flexFor(child) / totalFlex;
        child.layout(
          BoxConstraints.tightFor(width: width, height: gapHeight),
          parentUsesSize: true,
        );
      }
      parentData.offset = Offset(0, offsetY);
      offsetY += child.size.height;
      child = parentData.nextSibling;
    }

    size = Size(width, columnHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
