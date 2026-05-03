import 'package:flutter/material.dart';

class HomeInfoContainer extends StatelessWidget {
  final Widget child;

  const HomeInfoContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: child,
    );
  }
}
