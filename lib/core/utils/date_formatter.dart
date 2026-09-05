import 'package:intl/intl.dart';

/// Format tanggal ala Bahasa Indonesia, mis. "4 Jun 2024" / "4 Juni 2024, 14:30".
class DateFormatter {
  DateFormatter._();

  static final DateFormat _short = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _shortNoYear = DateFormat('d MMM', 'id_ID');
  static final DateFormat _long = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _day = DateFormat('E', 'id_ID');

  static String short(DateTime date) => _short.format(date);

  /// Format tanpa tahun, mis. "21 Mei" -- dipakai untuk label sumbu grafik
  /// "Ringkasan Arus Kas" agar tidak bergantung pada tahun tertentu.
  static String shortNoYear(DateTime date) => _shortNoYear.format(date);

  static String longWithTime(DateTime date) => _long.format(date);

  static String dayLabel(int index) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[index % days.length];
  }
}
