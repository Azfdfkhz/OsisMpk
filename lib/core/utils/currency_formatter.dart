import 'package:intl/intl.dart';

/// Format angka menjadi format Rupiah, mis. 12450000 -> "Rp 12.450.000".
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  static String format(num value) {
    return 'Rp ${_formatter.format(value)}';
  }

  /// Format dengan tanda +/- sesuai jenis transaksi, mis. "+Rp 2.000.000".
  static String formatSigned(num value, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(value.abs())}';
  }

  /// Format ringkas untuk sumbu grafik, mis. 4000000 -> "4 jt".
  static String formatCompactJuta(num value) {
    if (value == 0) return '0';
    final juta = value / 1000000;
    if (juta == juta.roundToDouble()) {
      return '${juta.toInt()} jt';
    }
    return '${juta.toStringAsFixed(1)} jt';
  }
}
