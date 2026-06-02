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
    final imageSize = compact ? 72 * scale : null;
    final gap = compact ? 12 * scale : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NugulLoadingIndicator(
            imageSize: imageSize,
            gap: gap,
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
