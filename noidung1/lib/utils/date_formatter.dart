import 'package:intl/intl.dart';

class DateFormatter {
  // "15/10/2024"
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // "Thứ 3, 15/10/2024"
  static String formatLong(DateTime date) {
    return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
  }

  // "Hôm nay", "Hôm qua", hoặc "15/10"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else if (dateOnly.year == today.year) {
      return DateFormat('dd/MM').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // "Tháng 10, 2024"
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM, yyyy', 'vi_VN').format(date);
  }
}