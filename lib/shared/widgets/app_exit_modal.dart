import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool?> showAppExitModal(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const _AppExitDialog(),
  );
}

/// go_router 루트 탭 화면에서 시스템 뒤로가기 시 종료 확인 모달을 띄웁니다.
class AppExitBackHandler extends StatefulWidget {
  const AppExitBackHandler({super.key, required this.child});

  final Widget child;

  /// 하위 [PopScope]/오버레이가 뒤로가기를 처리했을 때 호출합니다.
  /// 같은 백 이벤트가 부모까지 전달되어 앱 종료 모달이 뜨는 것을 막습니다.
  static void markBackHandledByChild() {
    _childHandledBack = true;
  }

  static bool _childHandledBack = false;

  static bool _consumeChildHandledBack() {
    if (!_childHandledBack) return false;
    _childHandledBack = false;
    return true;
  }

  @override
  State<AppExitBackHandler> createState() => _AppExitBackHandlerState();
}

class _AppExitBackHandlerState extends State<AppExitBackHandler> {
  bool _isHandlingBack = false;

  Future<void> _handleBack() async {
    if (_isHandlingBack) return;
    if (AppExitBackHandler._consumeChildHandledBack()) return;

    _isHandlingBack = true;
    try {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
        return;
      }

      final shouldExit = await showAppExitModal(context);
      if (shouldExit == true && mounted) {
        // 다이얼로그가 닫힌 뒤 Activity를 종료합니다. (finishAffinity 대신 표준 API 사용)
        await Future<void>.delayed(Duration.zero);
        if (mounted) {
          await SystemNavigator.pop();
        }
      }
    } finally {
      _isHandlingBack = false;
    }
  }

  void _scheduleHandleBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_handleBack());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // 하위 PopScope(위시 모달 등)가 먼저 처리할 수 있도록 다음 프레임에 실행
          _scheduleHandleBack();
        }
      },
      child: widget.child,
    );
  }
}

class _AppExitDialog extends StatefulWidget {
  const _AppExitDialog();

  @override
  State<_AppExitDialog> createState() => _AppExitDialogState();
}

class _AppExitDialogState extends State<_AppExitDialog> {
  bool _cancelPressed = false;
  bool _exitPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final horizontalInset = 21 * scale;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          24 * scale,
          31 * scale,
          24 * scale,
          31 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '앱을 종료하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20 * scale,
                color: AppColors.textPrimary,
                height: 1.29,
              ),
            ),
            SizedBox(height: 32 * scale),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _cancelPressed = true),
                    onTapUp: (_) {
                      setState(() => _cancelPressed = false);
                      Navigator.of(context).pop(false);
                    },
                    onTapCancel: () => setState(() => _cancelPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: _cancelPressed
                            ? AppColors.grey_300
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _exitPressed = true),
                    onTapUp: (_) {
                      setState(() => _exitPressed = false);
                      Navigator.of(context).pop(true);
                    },
                    onTapCancel: () => setState(() => _exitPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: _exitPressed
                            ? AppColors.red_500
                            : AppColors.red_600,
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '종료하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
