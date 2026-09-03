import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _shortDate = DateFormat('dd.MM.yyyy');
  static final DateFormat _longDate = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final DateFormat _time = DateFormat('HH:mm');
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static String shortDate(DateTime date) => _shortDate.format(date);
  static String longDate(DateTime date) => _longDate.format(date);
  static String time(DateTime date) => _time.format(date);
  static String currency(num amount) => _currency.format(amount);

  // 80000 -> "80.000" — Türkçe binlik ayracı (nokta).
  static String groupThousands(num amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    if (diff.inDays < 7) return '${diff.inDays} g';
    return shortDate(date);
  }

  // Beğeni/yorum gibi sayaçlar için: 1000+ değerleri "1.2K" şeklinde kısaltır.
  static String compactCount(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
