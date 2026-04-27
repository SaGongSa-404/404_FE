import 'package:flutter/material.dart';

class AlarmButton extends StatelessWidget {
  const AlarmButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications, size: 30),
      color: Colors.blue,
      onPressed: onPressed,
    );
  }
}
