abstract final class DateFormatter {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static String ymd(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  static String ymdHm(DateTime date) =>
      '${ymd(date)} ${_two(date.hour)}:${_two(date.minute)}';

  // 예시 — 로케일/패키지 사용 시
  // import 'package:intl/intl.dart';
  // static String localeDate(DateTime d) => DateFormat.yMMMd('ko').format(d);
}
