import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/core/utils/responsive_scale.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/providers/notification_provider.dart';
import 'package:fe_app/features/notification/providers/notification_sync_provider.dart';
import 'package:fe_app/features/notification/services/notification_router.dart';
import 'package:fe_app/features/notification/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isOpeningNotification = false;
  bool _isMarkingAllAsRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationSyncProvider).syncOnScreenEntered();
    });
  }

  Future<void> _onTapNotification(NotificationModel notification) async {
    if (_isOpeningNotification) return;
    _isOpeningNotification = true;

    try {
      final result =
          await ref.read(notificationSyncProvider).markAsRead(notification.id);

      if (result == MarkAsReadResult.notFound) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('만료되었거나 삭제된 알림입니다.')),
        );
        return;
      }

      if (!mounted) return;

      final route = NotificationRouter.resolveFromNotification(notification);
      if (route == null) return;

      if (NotificationRouter.isExternalUrl(route)) {
        final uri = Uri.parse(route);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      }

      if (!NotificationRouter.shouldNavigate(route)) return;

      try {
        await context.push(route);
        if (!mounted) return;
        await ref.read(notificationSyncProvider).refreshList();
      } catch (e) {
        debugPrint('알림 이동 실패: $e');
      }
    } finally {
      _isOpeningNotification = false;
    }
  }

  Future<void> _onTapMarkAllAsRead() async {
    if (_isMarkingAllAsRead) return;

    setState(() {
      _isMarkingAllAsRead = true;
    });

    try {
      await ref.read(notificationSyncProvider).markAllAsRead();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 전체 읽음 처리에 실패했어요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllAsRead = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = responsiveScale(context);
    final notificationsAsync = ref.watch(notificationListProvider(false));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 18 * scale),
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
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationSyncProvider).refreshListAndHomeSummary(),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                  Center(
                    child: Text(
                      '알림이 아직 없어요.',
                      style: TextStyle(
                          fontSize: 14 * scale, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }

            final unread = notifications.where((n) => !n.isRead).toList();
            final read = notifications.where((n) => n.isRead).toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: 24 * scale, vertical: 12 * scale),
              children: [
                if (unread.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: _MarkAllAsReadButton(
                      scale: scale,
                      isLoading: _isMarkingAllAsRead,
                      onTap: _onTapMarkAllAsRead,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                ],
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
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
              Center(child: Text('알림을 불러오지 못했습니다: $e')),
            ],
          ),
        ),
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

class _MarkAllAsReadButton extends StatelessWidget {
  const _MarkAllAsReadButton({
    required this.scale,
    required this.isLoading,
    required this.onTap,
  });

  final double scale;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isLoading
        ? AppColors.textSecondary.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(4 * scale),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 6 * scale),
        child: Text(
          '전체 읽음 표시',
          style: TextStyle(
            color: color,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: color,
            decorationThickness: 1,
          ),
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
        padding:
            EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 16 * scale),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFEEA0) : Colors.white,
          borderRadius: BorderRadius.circular(30 * scale),
          border: isUnread
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1),
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
                  if (notification.body != null &&
                      notification.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: isUnread
                            ? AppColors.textPrimary
                            : const Color(0xFF8E8E8E),
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
                      color: Color(0xFFE58D8D),
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
