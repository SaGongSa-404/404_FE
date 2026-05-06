import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';

class AlarmButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/alarm_icon.svg',
            width: size,
            height: size,
            colorFilter: color != null 
                ? ColorFilter.mode(color!, BlendMode.srcIn) 
                : null,
          ),
          onPressed: onPressed,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFE54327), // 빨간 계열
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
