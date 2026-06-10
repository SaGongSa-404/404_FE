import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/shared/widgets/nugul_loading_screen.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.compact = false,
  });

  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final ringSize = compact ? 72 * scale : null;
    final imageSize = compact ? 54 * scale : null;
    final strokeWidth = compact ? 4.5 * scale : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NugulLoadingIndicator(
            ringSize: ringSize,
            imageSize: imageSize,
            strokeWidth: strokeWidth,
          ),
          if (message != null) ...[
            SizedBox(height: 16 * scale),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16 * scale),
            ),
          ],
        ],
      ),
    );
  }
}
