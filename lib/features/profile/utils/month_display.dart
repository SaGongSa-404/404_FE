String yearMonthToDisplay(String yearMonth) {
  final parts = yearMonth.split('-');
  if (parts.length == 2) {
    return '${parts[0]}.${parts[1]}';
  }
  return yearMonth;
}

String displayToYearMonth(String display) {
  if (display.contains('-')) return display;
  return display.replaceAll('.', '-');
}
