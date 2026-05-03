import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlarmButton extends StatelessWidget {
  const AlarmButton({
    super.key,
    required this.onPressed,
    this.size = 30.0,
    this.color,
  });

  final VoidCallback onPressed;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        'assets/images/alarm_icon.svg',
        width: size,
        height: size,
        colorFilter: color != null 
            ? ColorFilter.mode(color!, BlendMode.srcIn) 
            : null,
      ),
      onPressed: onPressed,
    );
  }
}
