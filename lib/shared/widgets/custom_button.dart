import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22 * scale,
              width: 22 * scale,
              child: CircularProgressIndicator(strokeWidth: 2 * scale),
            )
          : Text(
              label,
              style: TextStyle(fontSize: 16 * scale),
            ),
    );
  }
}
