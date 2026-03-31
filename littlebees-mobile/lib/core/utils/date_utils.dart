import 'package:intl/intl.dart';

DateTime normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool isSameLogicalDay(DateTime a, DateTime b) {
  final first = normalizeDate(a);
  final second = normalizeDate(b);
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

bool isToday(DateTime date) => isSameLogicalDay(date, DateTime.now());

String formatShortDateLabel(
  DateTime date, {
  String locale = 'es',
  bool uppercaseToday = false,
}) {
  if (isToday(date)) {
    return uppercaseToday ? 'HOY' : 'Hoy';
  }

  final now = DateTime.now();
  final pattern = date.year == now.year ? 'd MMM' : 'd MMM y';
  return DateFormat(pattern, locale)
      .format(date)
      .replaceFirstMapped(
        RegExp(r'^[a-zA-Záéíóúñ]'),
        (match) => match.group(0)!.toUpperCase(),
      );
}

String formatLongDateLabel(DateTime date, {String locale = 'es'}) {
  if (isToday(date)) {
    return 'Hoy';
  }

  final formatted = DateFormat("EEEE d 'de' MMMM", locale).format(date);
  return formatted.replaceFirstMapped(
    RegExp(r'^[a-zA-Záéíóúñ]'),
    (match) => match.group(0)!.toUpperCase(),
  );
}
