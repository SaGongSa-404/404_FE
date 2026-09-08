import 'dart:async';

import 'package:fe_app/core/theme/app_theme.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/notification/models/notification_model.dart';
import 'package:fe_app/features/notification/models/notification_route_intent.dart';
import 'package:fe_app/features/notification/providers/fcm_navigation_provider.dart';
import 'package:fe_app/features/notification/providers/notification_deep_link_provider.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/providers/notification_navigation_provider.dart';
import 'package:fe_app/features/notification/providers/notification_settings_provider.dart';
import 'package:fe_app/features/notification/providers/notification_sync_provider.dart';
import 'package:fe_app/features/notification/services/notification_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationAppShell extends ConsumerStatefulWidget {
  const NotificationAppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationAppShell> createState() =>
      _NotificationAppShellState();
}

class _NotificationAppShellState extends ConsumerState<NotificationAppShell>
    with WidgetsBindingObserver {
  static const _bannerDuration = Duration(seconds: 4);

  late NotificationLiveNotifier _liveNotifier;
  Timer? _dismissTimer;
  String? _visibleBannerId;
  String? _handledDeepLinkKey;
  String? _openingRoute;
  bool _isOpeningNotificationsPage = false;
  bool _isForeground = true;

  bool _canPoll(AsyncValue authState) {
    if (!authState.hasValue || authState.value == null) return false;
    return authState.value!.onboardingStatus == 'COMPLETED';
  }

  void _syncPollingState(AsyncValue authState) {
    final live = ref.read(notificationLiveProvider.notifier);
    if (!_canPoll(authState)) {
      live.reset();
      return;
    }
    if (!_isForeground) return;
    unawaited(live.start());
  }

  @override
  void initState() {
    super.initState();
    _liveNotifier = ref.read(notificationLiveProvider.notifier);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPollingState(ref.read(authProvider));
      _flushPendingRoute();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dismissTimer?.cancel();
    _liveNotifier.pause();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final live = ref.read(notificationLiveProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      if (_canPoll(ref.read(authProvider))) {
        unawaited(live.resume());
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _isForeground = false;
      live.pause();
    }
  }

  void _flushPendingRoute() {
    final pending = ref.read(pendingNotificationRouteProvider);
    if (pending == null || pending.isEmpty) return;
    ref.read(pendingNotificationRouteProvider.notifier).state = null;
    _navigateToRoute(pending);
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
    await ref.read(notificationSyncProvider).markBannerAsRead(banner.id);
    if (!mounted) return;
    await _navigateFromNotification(banner);
  }

  Future<void> _openNotificationsPage() async {
    if (_isOpeningNotificationsPage) return;
    _isOpeningNotificationsPage = true;

    if (!mounted) {
      _isOpeningNotificationsPage = false;
      return;
    }

    final router = GoRouter.of(context);
    final location = router.state.uri.path;
    if (location == '/notifications') {
      _isOpeningNotificationsPage = false;
      return;
    }

    try {
      unawaited(
          ref.read(notificationSyncProvider).prepareNotificationsScreen());
      unawaited(
        context.push('/notifications').whenComplete(() {
          _isOpeningNotificationsPage = false;
        }),
      );
    } catch (error, stackTrace) {
      debugPrint('open notifications failed: $error\n$stackTrace');
      ref.read(pendingNotificationRouteProvider.notifier).state =
          '/notifications';
      _isOpeningNotificationsPage = false;
    }
  }

  Future<void> _navigateToRoute(String route) async {
    if (_openingRoute == route) return;
    _openingRoute = route;

    if (NotificationRouter.isExternalUrl(route)) {
      try {
        await NotificationRouter.launchExternalUrl(Uri.parse(route));
      } finally {
        _openingRoute = null;
      }
      return;
    }
    if (!NotificationRouter.shouldNavigate(route)) {
      _openingRoute = null;
      return;
    }

    final current = GoRouter.of(context).state.uri.toString();
    if (current == route) {
      _openingRoute = null;
      return;
    }

    try {
      await context.push(route);
    } catch (error, stackTrace) {
      debugPrint('notification navigation failed: $error\n$stackTrace');
      ref.read(pendingNotificationRouteProvider.notifier).state = route;
    } finally {
      _openingRoute = null;
    }
  }

  void _completeDeepLinkHandling() {
    ref.read(notificationDeepLinkProvider.notifier).consume();
    _handledDeepLinkKey = null;
  }

  Future<void> _navigateFromNotification(NotificationModel notification) async {
    final route = NotificationRouter.resolveFromNotification(notification);
    if (route == null) return;
    await _navigateToRoute(route);
  }

  Future<void> _handlePushOrDeepLinkOpen() async {
    await _openNotificationsPage();
  }

  Future<void> _handleDeepLink(NotificationRouteIntent intent) async {
    final key = '${intent.notificationId ?? ''}|${intent.targetPath}';
    if (_handledDeepLinkKey == key) return;
    _handledDeepLinkKey = key;

    if (!mounted) return;

    try {
      await _handlePushOrDeepLinkOpen();
    } finally {
      _completeDeepLinkHandling();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      _syncPollingState(next);
    });

    _liveNotifier = ref.watch(notificationLiveProvider.notifier);
    final liveState = ref.watch(notificationLiveProvider);
    final settings = ref.watch(notificationSettingsProvider);
    final deepLinkIntent = ref.watch(notificationDeepLinkProvider);
    final currentBanner =
        liveState.bannerQueue.isNotEmpty ? liveState.bannerQueue.first : null;

    ref.listen<NotificationRouteIntent?>(notificationDeepLinkProvider,
        (previous, next) {
      if (next != null) {
        _handleDeepLink(next);
      }
    });

    ref.listen<bool>(fcmNavigationProvider, (previous, next) {
      if (next) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            if (mounted) {
              await _handlePushOrDeepLinkOpen();
            }
          } finally {
            // 예외/조기 반환 시에도 플래그가 true로 고정되지 않도록 항상 consume.
            if (mounted) {
              ref.read(fcmNavigationProvider.notifier).consume();
            }
          }
        });
      }
    });

    ref.listen<String?>(pendingNotificationRouteProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _flushPendingRoute();
        });
      }
    });

    if (currentBanner?.id != _visibleBannerId) {
      _scheduleDismiss(currentBanner);
    }

    final showBanner =
        settings.enabled && deepLinkIntent == null && currentBanner != null;

    return Stack(
      children: [
        widget.child,
        if (showBanner)
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + 8,
            child: SafeArea(
              bottom: false,
              child: _NotificationBanner(
                notification: currentBanner,
                onTap: () => _handleBannerTap(currentBanner),
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
    final hasTitle = notification.title.trim().isNotEmpty;
    final hasBody =
        notification.body != null && notification.body!.trim().isNotEmpty;
    final primaryText =
        hasTitle ? notification.title : (hasBody ? notification.body! : '');
    final secondaryText = hasTitle && hasBody ? notification.body : null;

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
                    if (primaryText.isNotEmpty)
                      Text(
                        primaryText,
                        style: TextStyle(
                          fontSize: hasTitle ? 14 : 12,
                          fontWeight:
                              hasTitle ? FontWeight.w700 : FontWeight.w400,
                          color: hasTitle
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    if (secondaryText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        secondaryText,
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
