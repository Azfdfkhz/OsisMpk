# OSIS Finance — Flutter App

Aplikasi Bendahara OSIS/MPK dibangun sesuai README_OSIS_MPK.md dan desain UI (image.png).

## Menjalankan

```bash
# 1. Buat platform folders (android/ios/web) di sekitar lib/ ini:
flutter create . --project-name osis_finance --org com.osis

# 2. Install dependencies
flutter pub get

# 3. Jalankan (chrome untuk lihat layout desktop + sidebar)
flutter run -d chrome

# Mode mobile: resize window kecil atau jalankan di emulator/android
```

## Struktur (README bagian 27 — feature-based architecture)

```
lib/
├── main.dart
├── app/app_shell.dart              # Sidebar desktop (>=1000px) / bottom nav mobile
├── core/
│   ├── theme/app_theme.dart        # Design system: navy #1B2A4A, blue #2E5BFF,
│   │                               #   green #27AE60, red #EB5757, amber, purple
│   └── utils/formatters.dart       # formatRupiah, formatDate, formatPercent
├── data/
│   ├── models/models.dart          # Enums & model sesuai schema SQL
│   ├── repositories/mock_data.dart # Data demo (sesuai angka di desain)
│   └── services/supabase_service.dart  # Stub Phase 1 (README bagian 4)
└── features/
    ├── dashboard/                  # Desktop: 4 stat card + grafik arus kas (fl_chart)
    │                               # Mobile: kartu saldo + event aktif
    ├── events/                     # Tab Semua/Aktif/Selesai/Draft
    ├── transactions/               # Filter chip + Detail Transaksi + dokumentasi
    ├── rab/                        # Tab Ringkasan / Rincian / Persetujuan
    └── logistics/                  # Daftar barang + Dokumentasi Barang
```

## Yang sudah sesuai desain & README

- Angka demo persis dari image.png (Saldo 12.450.000, PORSENI 75%, RAB 62,5%, dll)
- Status flow transaksi/RAB (DRAFT→SUBMITTED→REVIEW→APPROVED→VOID) siap di-wiring ke Supabase
- Logistik terpisah dari keuangan (README bagian 20)
- Dokumentasi hanya menyimpan metadata, file di Google Drive (README bagian 17)
- Edge Function `backup-json` untuk backup JSON terjadwal (README bagian 19)

## Langkah berikutnya (roadmap README)

1. Phase 1: koneksikan `SupabaseService` (set SUPABASE_URL & SUPABASE_ANON_KEY via --dart-define), login Google OAuth
2. Ganti `MockData` dengan repository Supabase + Riverpod providers
3. Terapkan RLS policies lengkap dari schema_osis_finance.sql
4. Upload dokumentasi via backend ke Google Drive (service account)
5. Export RAB ke Google Sheets template (README bagian 16)
