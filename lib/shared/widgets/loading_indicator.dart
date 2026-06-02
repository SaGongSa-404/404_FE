import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
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
