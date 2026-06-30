import 'package:fe_app/core/network/network_error.dart';
import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

DateTime? _lastNetworkToastAt;
const Duration _networkToastCooldown = Duration(seconds: 2);

/// 화면 하단(바텀 네비 위쪽)에 잠깐 띄우는 캡슐 토스트.
void showCapsuleToast(
  BuildContext context, {
  required Color backgroundColor,
  required String text,
  Duration duration = const Duration(milliseconds: 2000),
  double bottomOffset = 88,
}) {
  if (text == kNetworkErrorMessage) {
    final now = DateTime.now();
    if (_lastNetworkToastAt != null &&
        now.difference(_lastNetworkToastAt!) < _networkToastCooldown) {
      return;
    }
    _lastNetworkToastAt = now;
  }

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      final scale = responsiveScale(ctx);
      final bottomPad = MediaQuery.paddingOf(ctx).bottom;
      final keyboardHeight = MediaQuery.viewInsetsOf(ctx).bottom;
      return Positioned(
        left: 0,
        right: 0,
        bottom: bottomPad + bottomOffset * scale + keyboardHeight,
        child: Material(
          color: Colors.transparent,
          child: CapsuleToast(
            backgroundColor: backgroundColor,
            text: text,
          ),
        ),
      );
    },
  );
  overlay.insert(entry);
  Future<void>.delayed(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

class CapsuleToast extends StatelessWidget {
  const CapsuleToast({
    super.key,
    required this.backgroundColor,
    required this.text,
  });

  final Color backgroundColor;
  final String text;

  static const double _stadiumRadius = 999;
  static const List<BoxShadow> _elevationShadow = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 12,
      offset: Offset(0, 5),
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final maxW = MediaQuery.sizeOf(context).width - 40 * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(_stadiumRadius),
            boxShadow: _elevationShadow,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 9 * scale),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 18 * scale,
                  height: 1.2,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
