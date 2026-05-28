String formatFeedTimestamp(DateTime createdAt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final local = createdAt.toLocal();
  final diff = reference.difference(local);

  if (diff.inSeconds < 60) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';

  final yy = (local.year % 100).toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mi = local.minute.toString().padLeft(2, '0');
  return '$yy.$mm.$dd $hh:$mi';
}
