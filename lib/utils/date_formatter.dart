String formatDate(DateTime date) {
  final day   = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year  = date.year.toString();
  final hour  = date.hour.toString().padLeft(2, '0');
  final min   = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$min';
}
