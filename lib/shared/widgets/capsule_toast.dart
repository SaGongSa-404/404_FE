import 'package:fe_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 화면 하단(바텀 네비 위쪽)에 잠깐 띄우는 캡슐 토스트.
void showCapsuleToast(
  BuildContext context, {
  required Color backgroundColor,
  required String text,
  Duration duration = const Duration(milliseconds: 2400),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      final bottomPad = MediaQuery.paddingOf(ctx).bottom;
      return Positioned(
        left: 0,
        right: 0,
        bottom: bottomPad + 88,
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
    entry.remove();
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
    final maxW = MediaQuery.sizeOf(context).width - 40;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_stadiumRadius),
            boxShadow: _elevationShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                text,
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
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
