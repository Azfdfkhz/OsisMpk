# Aplikasi Bendahara OSIS/MPK

## 1. Overview

Aplikasi ini merupakan sistem manajemen keuangan dan kegiatan untuk **OSIS/MPK** berbasis **Flutter/Dart** dengan **Supabase** sebagai backend utama.

Sistem tidak hanya digunakan untuk pencatatan kas, tetapi juga untuk:

- Pengelolaan pemasukan dan pengeluaran.
- Pengelolaan keuangan berdasarkan event/kegiatan.
- Penyusunan dan monitoring RAB.
- Dokumentasi bukti transaksi dan barang.
- Monitoring oleh pembina, ketua OSIS, dan pihak terkait.
- Sistem role dan permission yang dapat dikonfigurasi.
- Audit trail untuk menjaga transparansi dan akuntabilitas.
- Backup data dalam format JSON ke Google Drive.
- Integrasi Google Drive untuk dokumentasi.
- Integrasi Google Sheets untuk RAB dan laporan.

Tujuan utamanya adalah membuat pengelolaan keuangan OSIS/MPK menjadi **terstruktur, transparan, terdokumentasi, dan mudah dimonitor**, terutama karena data keuangan merupakan data yang sensitif.

---

# 2. Arsitektur Sistem

```text
                         ┌─────────────────────┐
                         │    Flutter / Dart   │
                         │   Android / iOS     │
                         └──────────┬──────────┘
                                    │
                           Google OAuth Login
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │    Supabase Auth    │
                         └──────────┬──────────┘
                                    │
                                    ▼
              ┌────────────────────────────────────────┐
              │                SUPABASE                 │
              │                                        │
              │ PostgreSQL                             │
              │ Authentication                         │
              │ Row Level Security (RLS)               │
              │ Realtime                               │
              │ Edge Functions                         │
              └───────────────────┬────────────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
             Google Drive   Google Sheets    JSON Backup
             Dokumentasi        RAB           ke Drive
```

### Prinsip utama

- **Supabase/PostgreSQL** adalah source of truth dan database utama.
- **Google Drive** digunakan untuk dokumentasi dan backup JSON.
- **Google Sheets** digunakan untuk RAB dan dokumen/laporan yang membutuhkan format spreadsheet.
- **Flutter** menjadi client/interface pengguna.
- **Google OAuth + Supabase Auth** menangani autentikasi.
- **RLS + permission system** menjadi lapisan keamanan utama.

---

# 3. Prinsip Data

## Database bukan JSON

JSON **tidak digunakan sebagai database utama**.

Struktur utama disimpan secara relasional di PostgreSQL:

```text
Supabase PostgreSQL
├── users/profiles
├── organizations
├── roles
├── permissions
├── events
├── cash_accounts
├── categories
├── transactions
├── budgets
├── budget_items
├── logistics_items
├── documents
└── audit_logs
```

JSON digunakan sebagai **snapshot/backup/export**.

Alurnya:

```text
Supabase Database
       │
       ▼
Generate JSON
       │
       ▼
Google Drive
```

---

# 4. Authentication

Sistem menggunakan:

```text
Google Account
      │
      ▼
Google OAuth
      │
      ▼
Supabase Auth
      │
      ▼
User Session
```

Pengguna tidak perlu membuat password khusus untuk aplikasi apabila autentikasi Google digunakan.

## Akun Google Organisasi

Untuk integrasi Google Drive dan Google Sheets, disarankan menggunakan **akun Google khusus organisasi/OSIS**, bukan akun pribadi salah satu anggota.

Akun tersebut digunakan untuk:

- Google Drive dokumentasi.
- Google Drive backup.
- Google Sheets RAB.
- Integrasi Google API.

Akun harus memiliki mekanisme recovery yang dikelola secara resmi oleh pihak yang berwenang.

---

# 5. User, Role, dan Permission

Sistem tidak hanya menggunakan role statis.

Konsepnya:

```text
User
 │
 ├── Role
 │
 └── Permission
```

Role menentukan kelompok/posisi pengguna, sedangkan permission menentukan kemampuan spesifik pengguna.

## Contoh Role

- Superadmin
- Admin
- Pembina
- Ketua OSIS
- Bendahara
- Logistik
- Sekretaris
- Anggota
- Viewer

Role dapat dikembangkan sesuai struktur organisasi.

---

# 6. Granular Permission

Permission dibuat berdasarkan modul dan aksi.

## Dashboard

```text
dashboard.view
```

## User Management

```text
user.view
user.create
user.update
user.delete
user.permission
```

## Transactions

```text
transaction.view
transaction.create
transaction.update
transaction.delete
transaction.approve
```

## Events

```text
event.view
event.create
event.update
event.delete
event.approve
```

## RAB

```text
rab.view
rab.create
rab.update
rab.delete
rab.submit
rab.approve
```

## Documents

```text
document.view
document.upload
document.delete
```

## Reports

```text
report.view
report.export
report.print
```

## Backup

```text
backup.create
backup.restore
backup.view
```

## Logistics

```text
logistics.view
logistics.upload
logistics.update
```

---

# 7. Permission Management

Superadmin dapat mengatur permission setiap user.

Contoh:

```text
User: Bendahara A

Dashboard
✓ Lihat Dashboard

Transaksi
✓ Lihat
✓ Tambah
✓ Edit
✗ Hapus
✓ Upload Bukti
✗ Approve

Event
✓ Lihat
✓ Tambah
✓ Edit
✗ Hapus

RAB
✓ Lihat
✓ Tambah
✓ Edit
✓ Submit
✗ Approve

Laporan
✓ Lihat
✓ Export

User Management
✗ Lihat
✗ Tambah
✗ Edit
✗ Hapus
```

Dengan sistem ini, dua orang dengan role yang sama dapat memiliki permission berbeda.

---

# 8. Role Template dan Permission Override

Untuk mempermudah administrasi, setiap role dapat memiliki permission default.

Contoh:

```text
Bendahara
├── transaction.view
├── transaction.create
├── transaction.update
├── document.upload
├── event.view
├── event.create
├── event.update
├── rab.view
├── rab.create
├── rab.update
├── rab.submit
├── report.view
└── report.export
```

Kemudian Superadmin dapat melakukan override untuk user tertentu.

Contoh:

```text
Role:
Bendahara

Default:
transaction.delete = false

User tertentu:
transaction.delete = true
```

---

# 9. Permission Scope

Permission dapat memiliki scope agar akses dapat dibatasi berdasarkan event.

Contoh:

```text
User: Logistik A

Event:
✓ PORSENI 2026
✓ Class Meeting 2026
✗ LDKS
✗ Study Tour
```

Atau:

```text
transaction.update
scope = EVENT
event_id = PORSENI-2026
```

Artinya user hanya dapat mengubah data pada event yang ditugaskan.

Scope yang dapat digunakan:

```text
ALL
EVENT
OWN
```

---

# 10. Security

Permission pada Flutter hanya digunakan untuk mengontrol UI.

Contoh:

```dart
if (hasPermission('transaction.update')) {
  // tampilkan tombol edit
}
```

Namun ini **bukan security utama**.

Security harus ditegakkan di Supabase:

```text
Flutter
   │
   ▼
Supabase
   │
   ▼
RLS Policy
   │
   ├── User memiliki permission?
   ├── User memiliki akses organization?
   ├── User memiliki akses event?
   └── Operasi diperbolehkan?
          │
       ALLOW / DENY
```

Row Level Security (RLS) wajib digunakan untuk data sensitif.

---

# 11. Superadmin

Superadmin merupakan role dengan kewenangan tertinggi.

Kemampuan dapat mencakup:

```text
user.manage
role.manage
permission.manage
organization.manage
transaction.manage
event.manage
rab.manage
document.manage
report.manage
backup.manage
```

Superadmin dapat berasal dari pembina atau ketua OSIS sesuai kebijakan organisasi.

Namun sebaiknya hak Superadmin diberikan secara eksplisit, bukan otomatis kepada semua Ketua OSIS.

---

# 12. Modul Keuangan

## Cash Account

Sistem dapat mendukung satu atau beberapa sumber kas.

Contoh:

```text
Kas OSIS
Kas Event
Kas Kegiatan
Kas Lainnya
```

Struktur:

```text
cash_accounts
├── id
├── organization_id
├── name
├── initial_balance
└── current_balance
```

## Transaction

Transaksi menggunakan konsep ledger.

Jenis transaksi:

```text
income
expense
transfer
adjustment
```

Contoh pemasukan:

```text
TRX-2026-001

Pemasukan
Rp 1.500.000

Sumber:
Dana Sekolah

Keterangan:
Dana kegiatan PORSENI
```

Contoh pengeluaran:

```text
TRX-2026-002

Pengeluaran
Rp 250.000

Event:
PORSENI 2026

Kategori:
Konsumsi

Keterangan:
Pembelian air mineral
```

---

# 13. Transaction Status

Transaksi sebaiknya memiliki status.

Contoh:

```text
DRAFT
SUBMITTED
REVIEW
APPROVED
REJECTED
VOID
COMPLETED
```

Alur:

```text
DRAFT
  ↓
SUBMITTED
  ↓
REVIEW
  ↓
APPROVED
  ↓
COMPLETED
```

Jika transaksi salah, sebaiknya tidak langsung dihapus.

Gunakan:

```text
VOID
```

Contoh:

```text
TRX-001
Rp 500.000
Status: VOID

Alasan:
Salah memasukkan nominal
```

Dengan demikian histori tetap tersedia.

---

# 14. Event Management

Event merupakan salah satu komponen utama.

Contoh:

```text
PORSENI 2026

Budget:
Rp 5.000.000

Pemasukan:
Rp 5.000.000

Pengeluaran:
Rp 3.250.000

Sisa:
Rp 1.750.000
```

Setiap event memiliki:

```text
Overview
RAB
Pemasukan
Pengeluaran
Logistik
Dokumentasi
Laporan
Audit
```

Dengan event-based finance, bendahara dapat memisahkan keuangan antar kegiatan.

---

# 15. RAB

RAB (Rencana Anggaran Biaya) digunakan untuk merencanakan kebutuhan sebelum event berjalan.

Contoh:

```text
RAB PORSENI 2026

Kategori          Qty     Harga       Total

Konsumsi          100     10.000      1.000.000
Dekorasi          1       500.000       500.000
Hadiah            5       200.000     1.000.000
ATK               1       250.000       250.000

----------------------------------------------
TOTAL                                2.750.000
```

RAB dapat memiliki workflow:

```text
DRAFT
  ↓
SUBMITTED
  ↓
REVIEW
  ↓
APPROVED
```

Setelah event berjalan, sistem dapat membandingkan:

```text
Budget
vs
Actual Spending
```

Contoh:

```text
Budget:
Rp 2.750.000

Realisasi:
Rp 2.600.000

Utilization:
94,5%
```

---

# 16. Google Sheets Integration

Google Sheets digunakan sebagai output/dokumen, bukan sebagai database utama.

Alur:

```text
Supabase
   │
   ▼
RAB Data
   │
   ▼
Google Sheets Template
```

Template dapat memiliki struktur:

```text
A1: RENCANA ANGGARAN BIAYA
A2: PORSENI 2026

A5: No
B5: Uraian
C5: Volume
D5: Satuan
E5: Harga
F5: Jumlah
```

Aplikasi dapat mengisi template secara otomatis.

---

# 17. Dokumentasi Keuangan

Setiap transaksi dapat memiliki dokumentasi.

Contoh:

```text
Pengeluaran
Rp 350.000
Konsumsi
PORSENI 2026

Dokumentasi:
✓ Foto barang
✓ Foto nota
```

Metadata dokumen disimpan di Supabase:

```text
documents
├── id
├── transaction_id
├── event_id
├── drive_file_id
├── file_name
├── mime_type
├── file_size
├── uploaded_by
└── created_at
```

Yang disimpan di database adalah **metadata dan referensi file**, sedangkan file fisiknya berada di Google Drive.

---

# 18. Google Drive

Struktur Drive yang disarankan:

```text
OSIS-FINANCE/
│
├── BACKUP/
│   ├── daily/
│   │   ├── 2026-09-03.json
│   │   ├── 2026-09-04.json
│   │   └── 2026-09-05.json
│   │
│   └── monthly/
│       ├── 2026-07.json
│       ├── 2026-08.json
│       └── 2026-09.json
│
└── EVENTS/
    │
    ├── PORSENI-2026/
    │   ├── RAB/
    │   ├── INCOME/
    │   ├── EXPENSE/
    │   └── DOCUMENTATION/
    │
    └── CLASSMEETING-2026/
        ├── RAB/
        ├── INCOME/
        ├── EXPENSE/
        └── DOCUMENTATION/
```

User tidak perlu mendapatkan akses penuh terhadap struktur Drive.

Aplikasi/backend yang menangani penyimpanan dan pengambilan file.

---

# 19. JSON Backup

JSON digunakan untuk backup database.

Contoh:

```json
{
  "backup_version": 1,
  "created_at": "2026-09-05T10:30:00Z",
  "organization": "OSIS",
  "data": {
    "cash_accounts": [],
    "transactions": [],
    "events": [],
    "budgets": []
  }
}
```

Backup sebaiknya dibuat secara terjadwal.

Alur yang disarankan:

```text
Supabase
   │
   ▼
Backup Process / Edge Function
   │
   ▼
Generate JSON
   │
   ▼
Google Drive
```

Tidak disarankan mengambil seluruh database melalui Flutter untuk membuat backup.

---

# 20. Modul Logistik

Logistik memiliki fungsi yang berbeda dengan Bendahara.

**Logistik tidak perlu memiliki akses ke data keuangan sensitif.**

Fokus utama:

- Mendokumentasikan barang.
- Memotret nota.
- Mendokumentasikan barang yang diterima.
- Mendokumentasikan kondisi barang.
- Mengupload bukti fisik.

Contoh:

```text
PORSENI 2026

Barang:
Air Mineral

Qty:
10 Dus

Status:
✓ Sudah diterima

Dokumentasi:

[ FOTO BARANG ]
[ FOTO NOTA ]

[ SELESAI ]
```

---

# 21. Logistics Item

Struktur:

```text
logistics_items
├── id
├── event_id
├── name
├── description
├── quantity
├── unit
├── status
├── created_by
└── created_at
```

Dokumentasi:

```text
logistics_documents
├── id
├── logistics_item_id
├── document_type
├── drive_file_id
├── file_name
├── uploaded_by
└── created_at
```

Jenis dokumentasi:

```text
item_photo
receipt
delivery
condition
other
```

---

# 22. Alur Bendahara dan Logistik

Sistem memisahkan **financial record** dan **physical evidence**.

Contoh:

```text
                 PENGELUARAN
                 Rp 350.000
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
        BENDAHARA           LOGISTIK
             │                 │
       Catat transaksi      Foto barang
             │              Foto nota
             │                 │
             └────────┬────────┘
                      ▼
                   SUPABASE
                      │
                      ▼
                 GOOGLE DRIVE
```

Pembina dapat melihat keduanya untuk melakukan monitoring.

---

# 23. Dashboard

Dashboard dapat menampilkan:

```text
Total Saldo
Pemasukan
Pengeluaran
Event Aktif
Transaksi Terbaru
RAB Aktif
Dokumentasi Belum Lengkap
```

Contoh:

```text
Total Saldo
Rp 4.250.000

Pemasukan Bulan Ini
Rp 2.500.000

Pengeluaran Bulan Ini
Rp 1.250.000

Event Aktif
3

Transaksi
127
```

Dashboard pembina dapat difokuskan pada monitoring tanpa memberikan kemampuan edit.

---

# 24. Realtime Monitoring

Supabase Realtime dapat digunakan untuk memperbarui informasi secara langsung.

Contoh:

```text
Bendahara
    │
    ▼
Tambah transaksi
    │
    ▼
Supabase
    │
    │ Realtime
    ▼
Pembina
```

Pembina tidak harus melakukan refresh manual untuk melihat perubahan tertentu.

---

# 25. Audit Log

Karena sistem menangani uang, audit log merupakan fitur penting.

Tabel:

```text
audit_logs
├── id
├── user_id
├── action
├── table_name
├── record_id
├── old_data
├── new_data
└── created_at
```

Contoh:

```text
5 September 2026 - 16:42

Pembina:
Bpk. X

Mengubah permission:

User:
Bendahara A

transaction.delete
FALSE → TRUE
```

Contoh perubahan transaksi:

```text
Bendahara A

TRX-001

Rp 250.000
→
Rp 300.000

5 September 2026
14:32
```

Audit log sebaiknya mencatat:

- Pembuatan data.
- Perubahan data.
- Approval.
- Rejection.
- Void.
- Penghapusan/archiving jika diperbolehkan.
- Perubahan permission.
- Perubahan role.
- Aktivitas backup/restore.

---

# 26. Struktur Database

Struktur awal yang disarankan:

```text
profiles
├── id
├── full_name
├── email
├── avatar_url
└── role/reference

organizations
├── id
├── name
└── school_name

organization_members
├── id
├── organization_id
├── user_id
└── role

roles
├── id
├── name
└── description

permissions
├── id
├── key
├── name
├── module
└── description

role_permissions
├── role_id
└── permission_id

user_roles
├── user_id
└── role_id

user_permissions
├── user_id
├── permission_id
└── allowed

cash_accounts
├── id
├── organization_id
├── name
├── initial_balance
└── current_balance

categories
├── id
├── name
└── type

events
├── id
├── organization_id
├── name
├── description
├── start_date
├── end_date
├── budget
└── status

transactions
├── id
├── organization_id
├── event_id
├── cash_account_id
├── category_id
├── type
├── amount
├── description
├── transaction_date
├── status
├── created_by
├── approved_by
├── created_at
└── updated_at

budgets
├── id
├── event_id
├── name
├── total
└── status

budget_items
├── id
├── budget_id
├── description
├── quantity
├── unit
├── estimated_price
└── total

logistics_items
├── id
├── event_id
├── name
├── description
├── quantity
├── unit
├── status
├── created_by
└── created_at

documents
├── id
├── transaction_id
├── event_id
├── drive_file_id
├── file_name
├── mime_type
├── file_size
├── uploaded_by
└── created_at

logistics_documents
├── id
├── logistics_item_id
├── document_type
├── drive_file_id
├── file_name
├── uploaded_by
└── created_at

audit_logs
├── id
├── user_id
├── action
├── table_name
├── record_id
├── old_data
├── new_data
└── created_at
```

Struktur tersebut merupakan baseline dan dapat disesuaikan saat ERD final dibuat.

---

# 27. Struktur Flutter

Disarankan menggunakan feature-based architecture:

```text
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── router/
│   └── utils/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── features/
│   │
│   ├── auth/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── controllers/
│   │
│   ├── dashboard/
│   ├── transactions/
│   ├── events/
│   ├── budgets/
│   ├── logistics/
│   ├── documents/
│   ├── reports/
│   └── settings/
│
└── main.dart
```

State management yang direkomendasikan:

```text
Riverpod
```

Alternatif:

```text
Bloc
```

---

# 28. Recommended Technology Stack

| Bagian | Teknologi |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| Backend | Supabase |
| Database | PostgreSQL |
| Authentication | Supabase Auth + Google OAuth |
| Security | PostgreSQL RLS |
| Realtime | Supabase Realtime |
| Server-side process | Supabase Edge Functions |
| Documentation | Google Drive API |
| RAB | Google Sheets API |
| Backup | JSON + Google Drive |
| State Management | Riverpod |
| Architecture | Feature-based / Clean-ish Architecture |

---

# 29. Skalabilitas

Target awal sekitar **100 user** bukan masalah besar untuk arsitektur ini.

Yang menjadi perhatian utama adalah:

- RLS yang benar.
- Struktur database yang terindeks dengan baik.
- Permission system.
- Pengelolaan file di Google Drive.
- Pembatasan akses berdasarkan organization dan event.
- Realtime subscription yang efisien.
- Pengelolaan API quota Google.
- Backup dan recovery.

100 user dapat dilayani dengan nyaman apabila arsitektur dan query dirancang dengan benar.

---

# 30. Prinsip Keamanan

Karena aplikasi menangani data keuangan, prinsip berikut harus diterapkan:

1. Jangan mengandalkan permission dari Flutter sebagai security.
2. Gunakan Supabase RLS.
3. Jangan memberikan akses penuh Google Drive kepada semua user.
4. Jangan menyimpan credential Google API secara langsung di aplikasi.
5. Jangan menggunakan akun Google pribadi sebagai akun organisasi utama.
6. Jangan hard-delete transaksi keuangan tanpa mekanisme audit.
7. Catat perubahan penting melalui audit log.
8. Pisahkan akses financial data dan logistics data.
9. Gunakan approval workflow untuk data yang membutuhkan persetujuan.
10. Backup database secara berkala.

---

# 31. Roadmap Pengembangan

## Phase 1 — Foundation

```text
Flutter
+
Supabase
+
Google Login

User
Role
Organization
```

## Phase 2 — Core Finance

```text
Cash
↓
Transactions
↓
Categories
↓
Balance
```

## Phase 3 — Event

```text
Event
↓
Event Budget
↓
Event Transactions
```

## Phase 4 — RAB

```text
RAB
↓
RAB Items
↓
Approval
↓
Actual vs Budget
```

## Phase 5 — Documentation

```text
Transaction
↓
Evidence
↓
Google Drive
↓
Document Metadata
```

## Phase 6 — Logistics

```text
Event
↓
Logistics Items
↓
Foto Barang
↓
Foto Nota
↓
Google Drive
```

## Phase 7 — Monitoring

```text
Dashboard Pembina
Realtime
Audit Log
Reports
```

## Phase 8 — Integration

```text
Google Sheets
JSON Backup
PDF
Excel/CSV
Automated Backup
```

---

# 32. Final System Concept

Sistem secara keseluruhan dapat digambarkan sebagai:

```text
                         SUPERADMIN
                    Pembina / Ketua OSIS
                              │
                 ┌────────────┴────────────┐
                 │                         │
            USER & ACCESS              MONITORING
                 │                         │
                 ▼                         ▼
        ROLE + PERMISSION             DASHBOARD
                 │                     AUDIT LOG
                 │                     APPROVAL
                 │
                 ▼
             BENDAHARA
                 │
        ┌────────┼────────┐
        │        │        │
        ▼        ▼        ▼
       KAS     EVENT      RAB
        │        │        │
        │        │        ▼
        │        │   GOOGLE SHEETS
        │        │
        │        ▼
        │     LOGISTIK
        │        │
        │   ┌────┴─────┐
        │   │          │
        │   ▼          ▼
        │ FOTO BARANG  FOTO NOTA
        │   │          │
        └───┴────┬─────┘
                 ▼
           GOOGLE DRIVE
                 │
          ┌──────┴──────┐
          ▼             ▼
   DOKUMENTATION      BACKUP JSON
```

## Core Philosophy

Aplikasi ini memisahkan tiga hal utama:

```text
FINANCIAL RECORD
       │
       ▼
    BENDAHARA

PHYSICAL EVIDENCE
       │
       ▼
    LOGISTIK

GOVERNANCE & MONITORING
       │
       ▼
PEMBINA / KETUA / SUPERADMIN
```

Dengan pendekatan tersebut, sistem tidak hanya mencatat **"uang keluar berapa"**, tetapi juga dapat menjawab:

- Uangnya digunakan untuk apa?
- Untuk event apa?
- Siapa yang mencatat?
- Siapa yang menyetujui?
- Apa bukti transaksinya?
- Barangnya benar-benar diterima atau tidak?
- Siapa yang mengubah data?
- Berapa anggaran awalnya?
- Berapa realisasinya?
- Berapa saldo tersisa?
- Siapa yang memiliki akses terhadap data tersebut?

Dengan demikian aplikasi dapat menjadi **sistem manajemen keuangan, kegiatan, dokumentasi, dan monitoring OSIS/MPK** yang terstruktur dan dapat dikembangkan lebih lanjut.
