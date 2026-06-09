import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

/// Figma-based confirm/cancel modal (412px design width).
Future<bool?> showConfirmBottomSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String actionLabel,
  bool destructive = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (context) => _ConfirmModal(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      destructive: destructive,
    ),
  );
}

class _ConfirmModal extends StatefulWidget {
  const _ConfirmModal({
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.destructive,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final bool destructive;

  @override
  State<_ConfirmModal> createState() => _ConfirmModalState();
}

class _ConfirmModalState extends State<_ConfirmModal> {
  bool _actionPressed = false;

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
          borderRadius: BorderRadius.circular(37 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 31 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20 * scale,
                      color: AppColors.textPrimary,
                      height: 1.29,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 12 * scale),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 16 * scale,
                        color: const Color(0xFF979797),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 27 * scale),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                    onTap: () => Navigator.of(context).pop(true),
                    onTapDown: (_) => setState(() => _actionPressed = true),
                    onTapUp: (_) => setState(() => _actionPressed = false),
                    onTapCancel: () => setState(() => _actionPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: widget.destructive
                            ? (_actionPressed
                                ? AppColors.red_500
                                : AppColors.red_400)
                            : (_actionPressed
                                ? AppColors.skyBlue_200
                                : AppColors.skyBlue_100),
                        borderRadius: BorderRadius.circular(57 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.actionLabel,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20 * scale,
                          color: widget.destructive
                              ? AppColors.white
                              : AppColors.textPrimary,
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
