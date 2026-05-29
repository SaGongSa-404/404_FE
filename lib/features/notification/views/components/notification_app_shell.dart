import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/models/notification_route_intent.dart';
import 'package:fe_app/features/notification/providers/notification_deep_link_provider.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationAppShell extends ConsumerStatefulWidget {
  const NotificationAppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationAppShell> createState() => _NotificationAppShellState();
}

class _NotificationAppShellState extends ConsumerState<NotificationAppShell>
    with WidgetsBindingObserver {
  static const _bannerDuration = Duration(seconds: 4);

  Timer? _dismissTimer;
  String? _visibleBannerId;
  String? _handledDeepLinkKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(ref.read(notificationLiveProvider.notifier).start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dismissTimer?.cancel();
    ref.read(notificationLiveProvider.notifier).pause();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final live = ref.read(notificationLiveProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      unawaited(live.resume());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      live.pause();
    }
  }

  void _scheduleDismiss(NotificationModel? banner) {
    _dismissTimer?.cancel();
    if (banner == null) return;
    _visibleBannerId = banner.id;
    _dismissTimer = Timer(_bannerDuration, () {
      if (!mounted) return;
      ref.read(notificationLiveProvider.notifier).consumeBanner(banner.id);
    });
  }

  Future<void> _handleBannerTap(NotificationModel banner) async {
    _dismissTimer?.cancel();
    await ref.read(notificationLiveProvider.notifier).markAsRead(banner.id);
    ref.read(notificationLiveProvider.notifier).consumeBanner(banner.id);
    if (!mounted) return;
    final path = banner.targetPath.trim();
    if (path.isEmpty || path == '/notifications') {
      return;
    }
    if (_isExternalUrl(path)) {
      final uri = Uri.parse(path);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    context.go(path);
  }

  Future<void> _handleDeepLink(NotificationRouteIntent intent) async {
    final key = '${intent.notificationId ?? ''}|${intent.targetPath}';
    if (_handledDeepLinkKey == key) return;
    _handledDeepLinkKey = key;

    final notificationId = intent.notificationId;
    if (notificationId != null && notificationId.isNotEmpty) {
      await ref.read(notificationLiveProvider.notifier).markAsRead(notificationId);
    }

    if (!mounted) return;
    if (_isExternalUrl(intent.targetPath)) {
      await launchUrl(Uri.parse(intent.targetPath), mode: LaunchMode.externalApplication);
      ref.read(notificationDeepLinkProvider.notifier).consume();
      return;
    }
    if (intent.targetPath.trim().isEmpty || intent.targetPath == '/notifications') {
      ref.read(notificationDeepLinkProvider.notifier).consume();
      return;
    }
    context.go(intent.targetPath);
    ref.read(notificationDeepLinkProvider.notifier).consume();
  }

  bool _isExternalUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'market';
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(notificationLiveProvider);
    final deepLinkIntent = ref.watch(notificationDeepLinkProvider);
    final currentBanner = liveState.bannerQueue.isNotEmpty ? liveState.bannerQueue.first : null;

    ref.listen<NotificationRouteIntent?>(notificationDeepLinkProvider, (previous, next) {
      if (next != null) {
        unawaited(_handleDeepLink(next));
      }
    });

    if (currentBanner?.id != _visibleBannerId) {
      _scheduleDismiss(currentBanner);
    }

    return Stack(
      children: [
        widget.child,
        if (deepLinkIntent == null && currentBanner != null)
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 8,
            child: SafeArea(
              bottom: false,
              child: _NotificationBanner(
                notification: currentBanner,
                onTap: () => unawaited(_handleBannerTap(currentBanner)),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.grey_200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE54327),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (notification.body != null && notification.body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




