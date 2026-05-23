extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
