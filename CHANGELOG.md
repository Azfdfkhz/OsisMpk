# Changelog

Semua perubahan penting pada aplikasi OSIS Finance dicatat di sini.

## [1.0.1] - Testing build

Perbaikan menyusul review kode terhadap `README_OSIS_MPK.md`,
`schema_osis_finance.sql`, dan desain UI "OSIS Finance".

### Fixed (bug yang menghalangi build / kompilasi)
- `EventModel.progressPercent` dan `BudgetCategoryBreakdown.percent`
  mengembalikan `num` dari `.clamp()`, bukan `double` seperti tipe
  kembalian getter-nya — menyebabkan galat tipe saat kompilasi. Ditambahkan
  `.toDouble()` eksplisit.
- Nilai `LinearProgressIndicator.value` pada `EventCard`,
  `BudgetCategoryTile`, dan tab "Ringkasan" RAB memiliki masalah tipe yang
  sama (`num` vs `double`); diperbaiki dengan `.toDouble()`.
- Perhitungan `interval` pada grafik "Ringkasan Arus Kas" (`CashFlowChart`)
  juga bertipe `num`, sekarang dikonversi eksplisit ke `double`.

### Fixed (kompatibilitas)
- Mengganti seluruh pemanggilan `Color.withValues(alpha: ...)` (API yang
  hanya tersedia di Flutter versi sangat baru) dengan `Color.withOpacity(...)`
  agar proyek tetap bisa di-build di rentang Flutter/Dart SDK yang
  dinyatakan pada `pubspec.yaml`.
- `main.dart` tidak lagi memanggil `Supabase.initialize()` saat
  `AppConstants.supabaseUrl`/`supabaseAnonKey` masih placeholder, sehingga
  aplikasi tidak mencoba konek ke host palsu (menghindari delay/hang saat
  testing tanpa Supabase asli) — sesuai catatan README "Cara menjalankan".

### Fixed (data & perilaku, agar tidak menyesatkan saat testing)
- `BudgetRepository.getBudgetForEvent()` sebelumnya SELALU mengembalikan
  data RAB PORSENI 2024 untuk event apa pun. Sekarang event lain
  mendapatkan RAB kosong ("belum dibuat") alih-alih ikut menampilkan
  angka PORSENI. Tab "Ringkasan" dan "Persetujuan" pada halaman RAB kini
  menampilkan status kosong yang sesuai.
- Grafik "Ringkasan Arus Kas" menampilkan dua kotak tooltip yang saling
  tumpang tindih (satu per garis) saat disentuh; sekarang hanya satu kotak
  gabungan sesuai desain.
- Label sumbu-x grafik arus kas sebelumnya menghapus teks `" 2024"` secara
  manual (rapuh bila data tahun lain ditambahkan); sekarang memakai format
  tanggal tanpa tahun (`DateFormatter.shortNoYear`).

### Fixed (kesesuaian dengan desain)
- Ikon Pemasukan/Pengeluaran pada Dashboard (`SummaryCard` & `ActivityTile`)
  memakai arah panah yang tertukar dibanding desain (Pemasukan = panah naik
  hijau, Pengeluaran = panah turun merah).
- Baris "Jenis Dokumentasi" pada halaman Dokumentasi Logistik dirapikan
  agar sesuai jumlah chip pada desain (Foto Barang/Nota/Penerimaan/Lainnya)
  dan dibungkus `Expanded` supaya tidak overflow di layar sempit.
- Halaman "Detail Transaksi" kini menampilkan badge "+N" pada thumbnail
  dokumentasi ke-3 saat dokumentasi lebih banyak dari yang muat ditampilkan,
  sesuai contoh pada desain.
- Menambahkan badge jumlah pengajuan pending pada menu "Persetujuan" di
  halaman Akun, dan label versi aplikasi di bagian bawah halaman tersebut.

### Changed
- Versi aplikasi dinaikkan ke `1.0.1+2` (build testing).

## [1.0.0] - Initial testing build
- Implementasi awal UI mobile (Dashboard, Event, Transaksi, RAB, Logistik,
  Dokumentasi) dengan data contoh (mock) mengikuti desain "OSIS Finance"
  dan `README_OSIS_MPK.md`.
