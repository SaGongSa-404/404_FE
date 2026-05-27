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
  bool _unreadOnly = false;

  Future<void> _onTapNotification(NotificationModel notification) async {
    try {
      await ref
          .read(notificationListProvider(_unreadOnly).notifier)
          .markAsRead(notification.id);
      await ref.read(notificationLiveProvider.notifier).markAsRead(notification.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('읽음 처리에 실패했어요: $error')),
        );
      }
    }

    if (!mounted) return;

    final targetPath = notification.targetPath.trim().isEmpty
        ? '/home'
        : notification.targetPath;

    try {
      context.go(targetPath);
    } catch (error) {
      debugPrint('notification routing error: $error');
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final notificationsAsync = ref.watch(notificationListProvider(_unreadOnly));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18 * scale),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 12 * scale),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('전체'),
                  selected: !_unreadOnly,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _unreadOnly = false);
                    }
                  },
                ),
                SizedBox(width: 8 * scale),
                ChoiceChip(
                  label: const Text('안 읽음'),
                  selected: _unreadOnly,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _unreadOnly = true);
                    }
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(notificationListProvider(_unreadOnly).notifier).refresh(),
                  child: const Text('새로고침'),
                ),
              ],
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return _EmptyNotificationState(
                    scale: scale,
                    unreadOnly: _unreadOnly,
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(
                      context,
                      notification: notification,
                      scale: scale,
                      onTap: () => _onTapNotification(notification),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorNotificationState(
                scale: scale,
                message: error.toString(),
                onRetry: () => ref.read(notificationListProvider(_unreadOnly).notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required NotificationModel notification,
    required double scale,
    required VoidCallback onTap,
  }) {
    final isNew = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24 * scale),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 16 * scale),
      decoration: BoxDecoration(
            color: isNew ? const Color(0xFFFDF1C7) : Colors.white,
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(
              color: isNew ? Colors.transparent : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: isNew ? FontWeight.w700 : FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    if (notification.body != null && notification.body!.isNotEmpty) ...[
                      SizedBox(height: 6 * scale),
                      Text(
                        notification.body!,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.time,
                    style: TextStyle(fontSize: 12 * scale, color: Colors.grey),
                  ),
                  if (isNew) ...[
                    SizedBox(height: 8 * scale),
                    Icon(Icons.circle, size: 6 * scale, color: const Color(0xFFE58D8D)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState({required this.scale, required this.unreadOnly});

  final double scale;
  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Text(
          unreadOnly ? '안 읽은 알림이 없어요.' : '알림이 아직 없어요.',
          style: TextStyle(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorNotificationState extends StatelessWidget {
  const _ErrorNotificationState({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '알림을 불러오지 못했어요.',
              style: TextStyle(
                fontSize: 14 * scale,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              message,
              style: TextStyle(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * scale),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
