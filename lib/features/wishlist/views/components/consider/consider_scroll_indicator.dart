import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:flutter/material.dart';

class ConsiderScrollIndicator extends StatelessWidget {
  const ConsiderScrollIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_downward,
            color: const Color(0xFF7A7A7A),
            size: 24 * scale,
          ),
          SizedBox(width: 8 * scale),
          Text(
            '스크롤',
            style: TextStyle(
              fontSize: 16 * scale,
              color: const Color(0xFF7A7A7A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
