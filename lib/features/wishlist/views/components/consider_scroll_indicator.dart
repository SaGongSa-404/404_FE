import 'package:flutter/material.dart';

class ConsiderScrollIndicator extends StatelessWidget {
  const ConsiderScrollIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_downward, color: Color(0xFF7A7A7A), size: 24),
          SizedBox(width: 8),
          Text(
            '스크롤',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7A7A7A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}