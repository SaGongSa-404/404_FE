import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class HomeInfoContainer extends StatelessWidget {
  final Widget child;

  const HomeInfoContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24 * scale, 32 * scale, 24 * scale, 24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: child,
    );
  }
}
