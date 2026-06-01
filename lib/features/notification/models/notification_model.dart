import 'package:fe_app/features/notification/services/notification_router.dart';

class NotificationModel {
  final String id;
  final String title;
  final String time;
  final bool isRead;
  final String targetPath;
  final String? body;
  final String? type;
  final String? itemId;
  final String? decisionId;
  final String? reminderId;
  final DateTime? createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    this.isRead = false,
    this.targetPath = '',
    this.body,
    this.type,
    this.itemId,
    this.decisionId,
    this.reminderId,
    this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _tryParseDateTime(json['createdAt']);
    final readAt = _tryParseDateTime(json['readAt']);

    return NotificationModel(
      id: _asString(json['id']),
      title: _asString(json['title']),
      time: _formatRelativeTime(createdAt),
      isRead: _asBool(json['read']),
      targetPath: _asNullableString(json['targetPath']) ?? '',
      body: _asNullableString(json['body']),
      type: _asNullableString(json['type']),
      itemId: _asNullableString(json['itemId']),
      decisionId: _asNullableString(json['decisionId']),
      reminderId: _asNullableString(json['reminderId']),
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  String? get resolvedRoute => NotificationRouter.resolveFromNotification(this);

  NotificationModel copyWith({
    bool? isRead,
    String? time,
    String? targetPath,
    String? body,
    String? type,
    String? itemId,
    String? decisionId,
    String? reminderId,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      targetPath: targetPath ?? this.targetPath,
      body: body ?? this.body,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      decisionId: decisionId ?? this.decisionId,
      reminderId: reminderId ?? this.reminderId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _asNullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

DateTime? _tryParseDateTime(Object? value) {
  if (value is DateTime) return value;
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${dateTime.month}/${dateTime.day}';
}
