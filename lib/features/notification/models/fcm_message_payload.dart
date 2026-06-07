import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM data payload 파싱.
class FcmMessagePayload {
  const FcmMessagePayload({
    this.notificationId,
    this.targetPath,
    this.title,
    this.body,
    this.itemId,
    this.decisionId,
    this.reminderId,
    this.type,
  });

  final String? notificationId;
  final String? targetPath;
  final String? title;
  final String? body;
  final String? itemId;
  final String? decisionId;
  final String? reminderId;
  final String? type;

  factory FcmMessagePayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    return FcmMessagePayload(
      notificationId: _pick(data, const [
        'notificationId',
        'notification_id',
        'id',
      ]),
      targetPath: _pick(data, const ['targetPath', 'target_path', 'path']),
      title: _pick(data, const ['title']) ?? notification?.title,
      body: _pick(data, const ['body']) ?? notification?.body,
      itemId: _pick(data, const ['itemId', 'item_id']),
      decisionId: _pick(data, const ['decisionId', 'decision_id']),
      reminderId: _pick(data, const ['reminderId', 'reminder_id']),
      type: _pick(data, const ['type']),
    );
  }

  factory FcmMessagePayload.fromMap(Map<String, dynamic> data) {
    return FcmMessagePayload(
      notificationId: _pick(data, const [
        'notificationId',
        'notification_id',
        'id',
      ]),
      targetPath: _pick(data, const ['targetPath', 'target_path', 'path']),
      title: _pick(data, const ['title']),
      body: _pick(data, const ['body']),
      itemId: _pick(data, const ['itemId', 'item_id']),
      decisionId: _pick(data, const ['decisionId', 'decision_id']),
      reminderId: _pick(data, const ['reminderId', 'reminder_id']),
      type: _pick(data, const ['type']),
    );
  }

  Map<String, String> toLocalNotificationPayload() {
    return {
      if (notificationId != null) 'notificationId': notificationId!,
      if (targetPath != null) 'targetPath': targetPath!,
      if (itemId != null) 'itemId': itemId!,
      if (decisionId != null) 'decisionId': decisionId!,
      if (reminderId != null) 'reminderId': reminderId!,
    };
  }

  static String? _pick(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
