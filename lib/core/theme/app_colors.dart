import 'package:flutter/material.dart';

/// Palet warna sesuai "Design System" pada desain OSIS Finance.
class AppColors {
  AppColors._();

  // Warna utama (sidebar, tombol, teks penting)
  static const Color navy = Color(0xFF11224B);
  static const Color navyDark = Color(0xFF0B1730);
  static const Color blue = Color(0xFF3B5BA9);

  // Warna status
  static const Color success = Color(0xFF2ECC87); // pemasukan / diterima
  static const Color danger = Color(0xFFEF5D66); // pengeluaran
  static const Color warning = Color(0xFFF5A623); // pending / belum
  static const Color purple = Color(0xFF8E7CF0); // aksen ungu (rapat, dsb)

  // Latar & permukaan
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE7E9F1);

  // Teks
  static const Color textPrimary = Color(0xFF171B2E);
  static const Color textSecondary = Color(0xFF8A8FA3);

  // Warna ikon kategori (dipetakan dari icon/color pada tabel categories)
  static const List<Color> categoryPalette = [
    Color(0xFF3B5BA9),
    Color(0xFF2ECC87),
    Color(0xFFEF5D66),
    Color(0xFFF5A623),
    Color(0xFF8E7CF0),
  ];

  static get primary => null;
}
