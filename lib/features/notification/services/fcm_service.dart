import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fe_app/core/firebase/firebase_bootstrap.dart';
import 'package:fe_app/core/services/notification_permission_service.dart';
import 'package:fe_app/features/auth/providers/auth_provider.dart';
import 'package:fe_app/features/notification/models/fcm_message_payload.dart';
import 'package:fe_app/features/notification/providers/fcm_navigation_provider.dart';
import 'package:fe_app/features/notification/providers/notification_live_provider.dart';
import 'package:fe_app/features/notification/services/push_token_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fe_app/features/notification/services/push_token_storage.dart';

const _androidChannelId = 'wigul_default';
const _androidChannelName = '위굴 알림';
const _localNotificationTapPayload = 'open_notifications';

final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService(
    ref.read(pushTokenServiceProvider),
    ref,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// 백그라운드 data 메시지 수신 시 로컬 알림 표시.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) return;
  await FirebaseBootstrap.initialize();
  await LocalNotificationPresenter.ensureInitialized(showBadge: true);
  await LocalNotificationPresenter.showFromRemoteMessage(message);
}

class FcmService {
  FcmService(this._pushTokenService, this._ref);

  final PushTokenService _pushTokenService;
  final Ref _ref;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  bool _started = false;
  String? _cachedToken;

  String? get cachedToken => _cachedToken;

  Future<void> start() async {
    if (_started || !FirebaseBootstrap.isInitialized) return;
    _started = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await LocalNotificationPresenter.ensureInitialized(
      onTap: _handleLocalNotificationTap,
    );

    final launchDetails = await LocalNotificationPresenter.launchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _handleLocalNotificationTap(launchDetails?.notificationResponse?.payload);
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handlePushOpen);
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_registerToken);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handlePushOpen(initial);
    }
  }

  Future<void> syncForAuthenticatedUser() async {
    if (!FirebaseBootstrap.isInitialized) return;

    final auth = _ref.read(authProvider);
    if (!auth.hasValue || auth.value == null) return;
    if (auth.value!.onboardingStatus != 'COMPLETED') return;

    await NotificationPermissionService.request();
    await _registerToken(await _resolveToken());
  }

  Future<void> deactivateCurrentToken() async {
    final token = _cachedToken ?? await _readStoredToken();
    if (token == null || token.isEmpty) return;

    try {
      await _pushTokenService.deactivateToken(token: token);
    } catch (error, stackTrace) {
      debugPrint('[fcm] deactivate failed: $error\n$stackTrace');
    } finally {
      await _clearStoredToken();
      _cachedToken = null;
    }
  }

  Future<String?> _resolveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        await _storeToken(token);
      }
      return token;
    } catch (error, stackTrace) {
      debugPrint('[fcm] getToken failed: $error\n$stackTrace');
      return _cachedToken ?? await _readStoredToken();
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;

    _cachedToken = token;
    await _storeToken(token);

    final auth = _ref.read(authProvider);
    if (!auth.hasValue || auth.value == null) return;

    try {
      final deviceId = await DeviceIdResolver.resolve();
      await _pushTokenService.registerToken(
        token: token,
        deviceId: deviceId,
      );
    } catch (error, stackTrace) {
      debugPrint('[fcm] register token failed: $error\n$stackTrace');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final payload = FcmMessagePayload.fromRemoteMessage(message);
    unawaited(_ref.read(notificationLiveProvider.notifier).enqueueFromPush(payload));
  }

  void _handlePushOpen(RemoteMessage message) {
    _ref.read(fcmNavigationProvider.notifier).requestOpenNotificationsPage();
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      _ref.read(fcmNavigationProvider.notifier).requestOpenNotificationsPage();
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final map = decoded.map((key, value) => MapEntry(key.toString(), value));
        FcmMessagePayload.fromMap(map);
      }
    } catch (_) {}

    _ref.read(fcmNavigationProvider.notifier).requestOpenNotificationsPage();
  }

  Future<void> _storeToken(String token) async {
    await PushTokenStorage.write(token);
  }

  Future<String?> _readStoredToken() async {
    return PushTokenStorage.read();
  }

  Future<void> _clearStoredToken() async {
    await PushTokenStorage.clear();
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
  }
}

abstract final class LocalNotificationPresenter {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> ensureInitialized({
    void Function(String? payload)? onTap,
    bool showBadge = false,
  }) async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response.payload);
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: '위굴 서비스 알림',
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    final payload = FcmMessagePayload.fromRemoteMessage(message);
    final title = payload.title?.trim();
    final body = payload.body?.trim();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await show(
      title: title ?? '위굴',
      body: body ?? '',
      payload: jsonEncode(payload.toLocalNotificationPayload()),
    );
  }

  static Future<NotificationAppLaunchDetails?> launchDetails() async {
    await ensureInitialized();
    return _plugin.getNotificationAppLaunchDetails();
  }

  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    await ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: '위굴 서비스 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload ?? _localNotificationTapPayload,
    );
  }
}

abstract final class DeviceIdResolver {
  static String? _cached;

  static Future<String?> resolve() async {
    if (_cached != null) return _cached;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('device_installation_id');
    if (stored != null && stored.isNotEmpty) {
      _cached = stored;
      return stored;
    }

    try {
      final plugin = DeviceInfoPlugin();
      if (!kIsWeb && Platform.isAndroid) {
        final info = await plugin.androidInfo;
        _cached = info.id;
      } else if (!kIsWeb && Platform.isIOS) {
        final info = await plugin.iosInfo;
        _cached = info.identifierForVendor;
      }
    } catch (_) {}

    _cached ??= DateTime.now().microsecondsSinceEpoch.toString();
    await prefs.setString('device_installation_id', _cached!);
    return _cached;
  }
}
