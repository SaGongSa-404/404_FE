import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Future<void> _onTapNotification(NotificationModel notification) async {
    try {
      // 1. 서버 및 로컬 읽음 처리 (전체 목록 기준이므로 unreadOnly: false)
      await ref.read(notificationListProvider(false).notifier).markAsRead(notification.id);
      await ref.read(notificationLiveProvider.notifier).markAsRead(notification.id);
    } catch (e) {
      debugPrint('읽음 처리 실패: $e');
    }

    if (!mounted) return;

    // 2. 타겟 페이지로 이동
    final path = notification.targetPath.trim();
    if (path.isEmpty || path == '/notifications') {
      return;
    }
    try {
      context.push(path);
    } catch (e) {
      debugPrint('이동 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final notificationsAsync = ref.watch(notificationListProvider(false));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 연그레이 배경
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                '알림이 아직 없어요.',
                style: TextStyle(fontSize: 14 * scale, color: AppColors.textSecondary),
              ),
            );
          }

          // 안 읽은 알림과 읽은 알림 분리
          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
            children: [
              if (unread.isNotEmpty) ...[
                _buildSectionTitle('읽지 않은 알림', scale),
                ...unread.map((n) => _NotificationCapsule(
                      notification: n,
                      scale: scale,
                      onTap: () => _onTapNotification(n),
                    )),
                const SizedBox(height: 24),
              ],
              if (read.isNotEmpty) ...[
                _buildSectionTitle('읽은 알림', scale),
                ...read.map((n) => _NotificationCapsule(
                      notification: n,
                      scale: scale,
                      onTap: () => _onTapNotification(n),
                    )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('알림을 불러오지 못했습니다: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale, bottom: 12 * scale),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8E8E8E),
        ),
      ),
    );
  }
}

class _NotificationCapsule extends StatelessWidget {
  final NotificationModel notification;
  final double scale;
  final VoidCallback onTap;

  const _NotificationCapsule({
    required this.notification,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 16 * scale),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFEEA0) : Colors.white, // 노란색(안읽음) / 흰색(읽음)
          borderRadius: BorderRadius.circular(30 * scale), // 캡슐형 둥근 모서리
          border: isUnread ? null : Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (notification.body != null && notification.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: isUnread ? AppColors.textPrimary : const Color(0xFF8E8E8E),
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: const Color(0xFFADADAD),
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6 * scale,
                    height: 6 * scale,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE58D8D), // 안 읽음 표시 레드 닷
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
