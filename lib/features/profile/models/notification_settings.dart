class NotificationSettings {
  const NotificationSettings({required this.notificationEnabled});

  final bool notificationEnabled;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationEnabled': notificationEnabled,
      };

  NotificationSettings copyWith({bool? notificationEnabled}) {
    return NotificationSettings(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}
