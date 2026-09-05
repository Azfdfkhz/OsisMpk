# OSIS Finance — Flutter App

**Status: v1.0.1 (testing build)** — lihat [`CHANGELOG.md`](./CHANGELOG.md)
untuk daftar perbaikan pada rilis ini.

Implementasi Flutter untuk aplikasi Bendahara OSIS/MPK, dibangun berdasarkan:

- `README_OSIS_MPK.md` (arsitektur, role/permission, modul keuangan, RAB, logistik, audit log)
- `schema_osis_finance.sql` (struktur tabel & view Supabase/PostgreSQL)
- Desain UI "OSIS Finance" (Dashboard, Event, Transaksi, RAB, Logistik, Dokumentasi)

## Cara menjalankan

```bash
flutter pub get
flutter run
```

Saat ini aplikasi berjalan dengan **data contoh (mock)** di `lib/data/services/mock_data.dart`
yang meniru persis angka & isi pada desain (Saldo Kas Rp12.450.000, event PORSENI 2024, dst),
sehingga bisa langsung dijalankan **tanpa perlu setup Supabase** terlebih dahulu.

## Menghubungkan ke Supabase asli

1. Isi `AppConstants.supabaseUrl` dan `AppConstants.supabaseAnonKey` di
   `lib/core/constants/app_constants.dart`.
2. Jalankan `schema_osis_finance.sql` di project Supabase Anda.
3. Ganti isi method pada `lib/data/repositories/*.dart` dari
   `MockData.xxx` menjadi query Supabase (`Supabase.instance.client.from('...')`),
   tanpa perlu mengubah kode UI di `lib/features/*` — karena UI hanya bergantung
   pada model & provider, bukan pada implementasi repository.

## Struktur folder

```
lib/
├── core/
│   ├── theme/       # warna, teks, ThemeData (Design System dari desain)
│   ├── constants/   # konstanta & status enum (sinkron dengan schema SQL)
│   ├── utils/       # formatter Rupiah & tanggal Indonesia
│   └── router/      # provider Riverpod (state & data)
├── data/
│   ├── models/      # 1:1 dengan tabel/​view di schema_osis_finance.sql
│   ├── repositories/# interface data (mock -> nanti diganti Supabase)
│   └── services/    # mock_data.dart — data contoh sesuai desain
└── features/
    ├── dashboard/   # Beranda: saldo, ringkasan, grafik arus kas, aktivitas
    ├── events/      # Event: tab Semua/Aktif/Selesai/Draft
    ├── transactions/# Transaksi: list, filter, detail transaksi
    ├── budgets/      # RAB: Ringkasan, Rincian, Persetujuan
    ├── logistics/    # Logistik: Daftar Barang, Dokumentasi Barang
    └── shell/        # Bottom navigation (Beranda/Event/+/Transaksi/Akun)
```

## Catatan penting (README bagian 10 & 30)

Permission di Flutter (kelak) **hanya untuk kontrol UI**. Keamanan sesungguhnya
harus ditegakkan lewat Row Level Security (RLS) di Supabase — lihat
`schema_osis_finance.sql` bagian 14 (`fn_has_permission`) dan policy RLS yang
sudah disediakan di sana.
