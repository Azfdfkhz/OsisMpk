import 'package:intl/intl.dart';

/// Rp 12.450.000
String formatRupiah(num value) =>
    'Rp ${NumberFormat('#,##0', 'id_ID').format(value)}';

/// 4 Jun 2024
String formatDate(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);

/// 4 Juni 2024, 14.30
String formatDateTime(DateTime d) =>
    DateFormat('d MMMM yyyy, HH.mm', 'id_ID').format(d);

/// 62,5%
String formatPercent(double value) {
  final s = value.toStringAsFixed(1).replaceAll('.', ',');
  return s.endsWith(',0') ? '${s.substring(0, s.length - 2)}%' : '$s%';
}
