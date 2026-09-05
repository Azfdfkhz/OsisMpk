import 'package:flutter/material.dart';

import '../models/models.dart';

/// Data mock untuk UI sesuai desain (image.png).
/// Nantinya digantikan oleh repository Supabase
/// (README bagian 3: PostgreSQL adalah source of truth).
class MockData {
  MockData._();

  static const AppUser currentUser = AppUser(
    name: 'Azmi',
    role: 'Bendahara OSIS',
  );

  // Ringkasan dashboard (kartu atas desain)
  static const int saldoKas = 12450000;
  static const int totalPemasukan = 18750000;
  static const int totalPengeluaran = 6300000;
  static const int eventAktifCount = 5;
  static const int pendingApprovals = 3;

  static final List<EventItem> events = [
    const EventItem(
      name: 'PORSENI 2024',
      dateLabel: '12 Mei - 20 Jun 2024',
      budget: 10000000,
      progress: 75,
      status: EvStatus.active,
      icon: Icons.emoji_events_outlined,
    ),
    const EventItem(
      name: 'Class Meeting',
      dateLabel: '1 Mei - 10 Mei 2024',
      budget: 3500000,
      progress: 60,
      status: EvStatus.active,
      icon: Icons.groups_outlined,
    ),
    const EventItem(
      name: 'Study Tour',
      dateLabel: '20 Apr - 25 Apr 2024',
      budget: 15000000,
      progress: 100,
      status: EvStatus.completed,
      icon: Icons.directions_bus_outlined,
    ),
    const EventItem(
      name: 'Rapat OSIS',
      dateLabel: 'Berlangsung',
      budget: 1250000,
      progress: 30,
      status: EvStatus.active,
      icon: Icons.groups_2_outlined,
    ),
    const EventItem(
      name: 'LDK OSIS',
      dateLabel: '10 Mar - 12 Mar 2024',
      budget: 2500000,
      progress: 100,
      status: EvStatus.completed,
      icon: Icons.menu_book_outlined,
    ),
  ];

  static EventItem get porseni => events.first;

  static final List<TransactionModel> transactions = [
    TransactionModel(
      title: 'Pembelian konsumsi',
      eventName: 'Event Class Meeting',
      type: TxType.expense,
      amount: 350000,
      date: DateTime(2024, 6, 4, 14, 30),
      category: 'Konsumsi',
      paymentMethod: 'Tunai',
      note: 'Konsumsi untuk panitia dan peserta.',
      docCount: 3,
    ),
    TransactionModel(
      title: 'Pemasukan sponsor',
      eventName: 'Event PORSENI 2024',
      type: TxType.income,
      amount: 2000000,
      date: DateTime(2024, 6, 3),
      category: 'Dana Sponsor',
      paymentMethod: 'Transfer',
    ),
    TransactionModel(
      title: 'Pembelian banner',
      eventName: 'Event PORSENI 2024',
      type: TxType.expense,
      amount: 250000,
      date: DateTime(2024, 6, 2),
      category: 'Dekorasi',
      paymentMethod: 'Tunai',
      docCount: 2,
    ),
    TransactionModel(
      title: 'Pembelian ATK',
      eventName: 'Event Rapat OSIS',
      type: TxType.expense,
      amount: 120000,
      date: DateTime(2024, 6, 1),
      category: 'ATK',
      paymentMethod: 'Tunai',
      docCount: 1,
    ),
    TransactionModel(
      title: 'Sewa sound system',
      eventName: 'Event PORSENI 2024',
      type: TxType.expense,
      amount: 1000000,
      date: DateTime(2024, 5, 30),
      category: 'Sewa Peralatan',
      paymentMethod: 'Transfer',
      docCount: 1,
    ),
    TransactionModel(
      title: 'Pemasukan dana kelas',
      eventName: 'Event Class Meeting',
      type: TxType.income,
      amount: 1500000,
      date: DateTime(2024, 5, 28),
      category: 'Dana Kelas',
      paymentMethod: 'Tunai',
    ),
  ];

  static List<ActivityModel> get activities => transactions
      .map(
        (t) => ActivityModel(
          title: t.title,
          eventName: t.eventName,
          type: t.type,
          amount: t.amount,
          date: t.date,
        ),
      )
      .toList();

  static final List<LogisticsItem> logisticsItems = const [
    LogisticsItem(name: 'Air Mineral', qty: 10, unit: 'Dus', received: true),
    LogisticsItem(name: 'Banner', qty: 3, unit: 'Buah', received: true),
    LogisticsItem(name: 'Konsumsi Panitia', qty: 20, unit: 'Pack', received: true),
    LogisticsItem(name: 'Dekorasi Panggung', qty: 1, unit: 'Set', received: false),
    LogisticsItem(name: 'ATK', qty: 1, unit: 'Paket', received: false),
  ];

  // RAB PORSENI 2024 — tab Ringkasan (angka sesuai desain)
  static const int rabTotal = 10000000;
  static const int rabRealisasi = 6250000;

  static const List<RabCategory> rabCategories = [
    RabCategory(name: 'Konsumsi', used: 2500000, budget: 4000000),
    RabCategory(name: 'Perlengkapan', used: 1200000, budget: 2000000),
    RabCategory(name: 'Dekorasi', used: 850000, budget: 1500000),
    RabCategory(name: 'Lain-lain', used: 1700000, budget: 2500000),
  ];

  // RAB PORSENI 2024 — tab Rincian (contoh README bagian 15)
  static const List<RabItem> rabItems = [
    RabItem(description: 'Konsumsi', qty: 100, unit: 'pcs', price: 10000),
    RabItem(description: 'Dekorasi', qty: 1, unit: 'paket', price: 500000),
    RabItem(description: 'Hadiah', qty: 5, unit: 'pcs', price: 200000),
    RabItem(description: 'ATK', qty: 1, unit: 'paket', price: 250000),
  ];

  /// 30 titik arus kas terakhir (grafik desktop).
  static List<CashFlowPoint> get cashFlow30 => List.generate(
        30,
        (i) => CashFlowPoint(
          1200000 +
              600000 * ((i * 7) % 5) +
              (i == 20 ? 1400000 : 0) +
              200000 * ((i * 3) % 4),
          400000 + 250000 * ((i * 5) % 5) + (i == 20 ? 600000 : 0),
        ),
      );

  static const List<String> cashFlowLabels = [
    '7 Mei', '14 Mei', '21 Mei', '28 Mei', '4 Jun',
  ];
}
