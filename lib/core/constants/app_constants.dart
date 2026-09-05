/// Konstanta umum aplikasi.
///
/// NOTE: Nilai Supabase di bawah ini adalah placeholder.
/// Ganti dengan Project URL & anon key dari dashboard Supabase Anda
/// sebelum menjalankan aplikasi (jangan commit key asli ke repo publik).
class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR-ANON-KEY';

  static const String appName = 'OSIS Finance';
  static const String appTagline = 'Kelola Keuangan. Transparan. Bertanggung Jawab.';

  // Versi build saat ini (lihat CHANGELOG.md). Ditampilkan di halaman Akun
  // supaya tester tahu build mana yang sedang berjalan.
  static const String appVersion = '1.0.1';
  static const bool isTestingBuild = true;

  /// True jika kredensial Supabase masih placeholder (belum diisi).
  /// Dipakai supaya `main.dart` tidak mencoba konek ke host palsu saat
  /// aplikasi masih berjalan dengan MockData (README: "Cara menjalankan").
  static bool get hasSupabaseCredentials =>
      supabaseUrl != 'https://YOUR-PROJECT.supabase.co' &&
      supabaseAnonKey != 'YOUR-ANON-KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}

/// Nama status yang dipakai di banyak tempat (event, transaksi, RAB, logistik).
/// Nilainya harus sinkron dengan ENUM pada schema_osis_finance.sql.
class StatusKeys {
  StatusKeys._();

  // event_status
  static const draft = 'DRAFT';
  static const active = 'ACTIVE';
  static const completed = 'COMPLETED';
  static const cancelled = 'CANCELLED';

  // logistics_status
  static const pending = 'PENDING';
  static const received = 'RECEIVED';
  static const issue = 'ISSUE';
}
