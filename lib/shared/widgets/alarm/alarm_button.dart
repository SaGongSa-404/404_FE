import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlarmButton extends ConsumerWidget {
  const AlarmButton({
    super.key,
    required this.onPressed,
    this.size,
    this.color,
  });

  final VoidCallback onPressed;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = responsiveScale(context);
    final iconSize = size ?? 30 * scale;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/alarm_icon.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          ),
          onPressed: onPressed,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8 * scale,
            top: 8 * scale,
            child: Container(
              padding: EdgeInsets.all(4 * scale),
              decoration: const BoxDecoration(
                color: Color(0xFFE54327),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16 * scale,
                minHeight: 16 * scale,
              ),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10 * scale,
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
