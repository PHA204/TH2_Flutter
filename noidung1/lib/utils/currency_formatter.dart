import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format số tiền VND: 50000 -> "50.000 đ"
  static String format(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }

  // Format ngắn gọn: 1500000 -> "1.5M"
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B đ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K đ';
    }
    return '${amount.toStringAsFixed(0)} đ';
  }
}