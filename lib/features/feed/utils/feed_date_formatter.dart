String formatFeedTimestamp(DateTime createdAt, {DateTime? now}) {
  final local = createdAt.toLocal();
  final yy = (local.year % 100).toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mi = local.minute.toString().padLeft(2, '0');
  return '$yy.$mm.$dd $hh:$mi';
}
