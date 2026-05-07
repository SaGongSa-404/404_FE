class NotificationModel {
  final String id;
  final String title;
  final String time;
  final bool isRead;
  final String targetPath;

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    this.isRead = false,
    this.targetPath = '/home',
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      time: time,
      isRead: isRead ?? this.isRead,
      targetPath: targetPath,
    );
  }
}
