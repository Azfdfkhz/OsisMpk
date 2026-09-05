import '../models/budget_item_model.dart';
import '../models/budget_model.dart';
import '../models/dashboard_models.dart';
import '../models/document_model.dart';
import '../models/event_model.dart';
import '../models/logistics_document_model.dart';
import '../models/logistics_item_model.dart';
import '../models/profile_model.dart';
import '../models/transaction_model.dart';

/// Data contoh (mock) yang meniru persis angka & isi pada desain UI
/// "OSIS Finance". Nantinya kelas ini digantikan oleh pemanggilan
/// Supabase melalui data/repositories/*, tanpa mengubah UI di features/*
/// (lihat README bagian 27 - struktur Flutter berbasis repository).
class MockData {
  MockData._();

  static const currentUser = ProfileModel(
    id: 'user-azmi',
    fullName: 'Azmi',
    email: 'azmi@osis.sch.id',
    roleName: 'Bendahara',
  );

  // ---------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------
  static const dashboardSummary = DashboardSummary(
    totalSaldoKas: 12450000,
    totalPemasukan: 18750000,
    totalPengeluaran: 6300000,
    eventAktif: 5,
  );

  static final cashFlow = <CashFlowPoint>[
    CashFlowPoint(tanggal: DateTime(2024, 5, 7), pemasukan: 1200000, pengeluaran: 700000),
    CashFlowPoint(tanggal: DateTime(2024, 5, 14), pemasukan: 2600000, pengeluaran: 1000000),
    CashFlowPoint(tanggal: DateTime(2024, 5, 21), pemasukan: 3200000, pengeluaran: 1450000),
    CashFlowPoint(tanggal: DateTime(2024, 5, 28), pemasukan: 2100000, pengeluaran: 1100000),
    CashFlowPoint(tanggal: DateTime(2024, 6, 4), pemasukan: 2450000, pengeluaran: 1600000),
  ];

  static final activities = <ActivityItem>[
    ActivityItem(
      title: 'Pembelian konsumsi',
      subtitle: 'Event Class Meeting',
      amount: 350000,
      isIncome: false,
      date: DateTime(2024, 6, 4),
    ),
    ActivityItem(
      title: 'Pemasukan sponsor',
      subtitle: 'Event PORSENI 2024',
      amount: 2000000,
      isIncome: true,
      date: DateTime(2024, 6, 3),
    ),
    ActivityItem(
      title: 'Pembelian banner',
      subtitle: 'Event PORSENI 2024',
      amount: 250000,
      isIncome: false,
      date: DateTime(2024, 6, 2),
    ),
    ActivityItem(
      title: 'Pembelian ATK',
      subtitle: 'Event Rapat OSIS',
      amount: 120000,
      isIncome: false,
      date: DateTime(2024, 6, 1),
    ),
  ];

  static const reminder = ReminderItem(
    title: 'Pengingat',
    description: 'RAB PORSENI 2024 menunggu persetujuan pembina.',
  );

  // ---------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------
  static final events = <EventModel>[
    EventModel(
      id: 'evt-porseni',
      name: 'PORSENI 2024',
      icon: 'star',
      startDate: DateTime(2024, 5, 12),
      endDate: DateTime(2024, 6, 20),
      totalBudget: 10000000,
      realisasi: 7500000,
      pemasukan: 9500000,
      status: 'ACTIVE',
    ),
    EventModel(
      id: 'evt-classmeeting',
      name: 'Class Meeting',
      icon: 'trending_up',
      startDate: DateTime(2024, 5, 1),
      endDate: DateTime(2024, 5, 10),
      totalBudget: 3500000,
      realisasi: 2100000,
      pemasukan: 1500000,
      status: 'ACTIVE',
    ),
    EventModel(
      id: 'evt-studytour',
      name: 'Study Tour',
      icon: 'directions_bus',
      startDate: DateTime(2024, 4, 20),
      endDate: DateTime(2024, 4, 25),
      totalBudget: 15000000,
      realisasi: 15000000,
      pemasukan: 15000000,
      status: 'COMPLETED',
    ),
    EventModel(
      id: 'evt-rapatosis',
      name: 'Rapat OSIS',
      icon: 'groups',
      startDate: DateTime(2024, 5, 1),
      endDate: null,
      totalBudget: 1250000,
      realisasi: 375000,
      pemasukan: 0,
      status: 'ACTIVE',
    ),
    EventModel(
      id: 'evt-ldk',
      name: 'LDK OSIS',
      icon: 'menu_book',
      startDate: DateTime(2024, 3, 10),
      endDate: DateTime(2024, 3, 12),
      totalBudget: 2500000,
      realisasi: 2500000,
      pemasukan: 2500000,
      status: 'COMPLETED',
    ),
  ];

  static EventModel eventById(String id) => events.firstWhere((e) => e.id == id);

  // ---------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------
  static final transactions = <TransactionModel>[
    TransactionModel(
      id: 'trx-1',
      eventId: 'evt-classmeeting',
      eventName: 'Event Class Meeting',
      categoryName: 'Konsumsi',
      type: 'expense',
      amount: 350000,
      description: 'Pembelian konsumsi',
      paymentMethod: 'Tunai',
      transactionDate: DateTime(2024, 6, 4, 14, 30),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
      note: 'Konsumsi untuk panitia dan peserta.',
      documents: const [
        DocumentModel(id: 'doc-1', driveFileId: 'drv-1', fileName: 'nota1.jpg'),
        DocumentModel(id: 'doc-2', driveFileId: 'drv-2', fileName: 'nota2.jpg'),
        DocumentModel(id: 'doc-3', driveFileId: 'drv-3', fileName: 'nota3.jpg'),
        DocumentModel(id: 'doc-4', driveFileId: 'drv-4', fileName: 'nota4.jpg'),
        DocumentModel(id: 'doc-5', driveFileId: 'drv-5', fileName: 'nota5.jpg'),
      ],
    ),
    TransactionModel(
      id: 'trx-2',
      eventId: 'evt-porseni',
      eventName: 'Event PORSENI 2024',
      categoryName: 'Dana Sponsor',
      type: 'income',
      amount: 2000000,
      description: 'Pemasukan sponsor',
      paymentMethod: 'Transfer',
      transactionDate: DateTime(2024, 6, 3, 10, 0),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
    ),
    TransactionModel(
      id: 'trx-3',
      eventId: 'evt-porseni',
      eventName: 'Event PORSENI 2024',
      categoryName: 'Dekorasi',
      type: 'expense',
      amount: 250000,
      description: 'Pembelian banner',
      paymentMethod: 'Tunai',
      transactionDate: DateTime(2024, 6, 2, 9, 15),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
    ),
    TransactionModel(
      id: 'trx-4',
      eventId: 'evt-rapatosis',
      eventName: 'Event Rapat OSIS',
      categoryName: 'ATK',
      type: 'expense',
      amount: 120000,
      description: 'Pembelian ATK',
      paymentMethod: 'Tunai',
      transactionDate: DateTime(2024, 6, 1, 11, 0),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
    ),
    TransactionModel(
      id: 'trx-5',
      eventId: 'evt-porseni',
      eventName: 'Event PORSENI 2024',
      categoryName: 'Sewa Peralatan',
      type: 'expense',
      amount: 1000000,
      description: 'Sewa sound system',
      paymentMethod: 'Transfer',
      transactionDate: DateTime(2024, 5, 30, 16, 0),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
    ),
    TransactionModel(
      id: 'trx-6',
      eventId: 'evt-classmeeting',
      eventName: 'Event Class Meeting',
      categoryName: 'Dana Kelas',
      type: 'income',
      amount: 1500000,
      description: 'Pemasukan dana kelas',
      paymentMethod: 'Transfer',
      transactionDate: DateTime(2024, 5, 28, 8, 0),
      status: 'COMPLETED',
      createdByName: 'Azmi (Bendahara)',
    ),
  ];

  static List<TransactionModel> transactionsForEvent(String eventId) =>
      transactions.where((t) => t.eventId == eventId).toList();

  // ---------------------------------------------------------------
  // RAB / Budget (contoh untuk PORSENI 2024)
  // ---------------------------------------------------------------
  static final budgetPorseni = BudgetModel(
    id: 'bud-porseni',
    eventId: 'evt-porseni',
    name: 'RAB PORSENI 2024',
    total: 10000000,
    status: 'APPROVED',
    items: [
      BudgetItemModel(id: 'bi-1', budgetId: 'bud-porseni', description: 'Konsumsi', quantity: 400, unit: 'pcs', estimatedPrice: 10000),
      BudgetItemModel(id: 'bi-2', budgetId: 'bud-porseni', description: 'Perlengkapan', quantity: 1, unit: 'paket', estimatedPrice: 2000000),
      BudgetItemModel(id: 'bi-3', budgetId: 'bud-porseni', description: 'Dekorasi', quantity: 1, unit: 'set', estimatedPrice: 1500000),
      BudgetItemModel(id: 'bi-4', budgetId: 'bud-porseni', description: 'Lain-lain', quantity: 1, unit: 'paket', estimatedPrice: 2500000),
    ],
  );

  /// Meniru hasil view `v_budget_category_breakdown` untuk RAB PORSENI 2024.
  static const budgetBreakdownPorseni = <BudgetCategoryBreakdown>[
    BudgetCategoryBreakdown(categoryName: 'Konsumsi', anggaranKategori: 4000000, realisasiKategori: 2500000),
    BudgetCategoryBreakdown(categoryName: 'Perlengkapan', anggaranKategori: 2000000, realisasiKategori: 1200000),
    BudgetCategoryBreakdown(categoryName: 'Dekorasi', anggaranKategori: 1500000, realisasiKategori: 850000),
    BudgetCategoryBreakdown(categoryName: 'Lain-lain', anggaranKategori: 2500000, realisasiKategori: 1700000),
  ];

  // ---------------------------------------------------------------
  // Logistics (contoh untuk PORSENI 2024)
  // ---------------------------------------------------------------
  static final logisticsItemsPorseni = <LogisticsItemModel>[
    LogisticsItemModel(
      id: 'log-1',
      eventId: 'evt-porseni',
      name: 'Air Mineral',
      quantity: 10,
      unit: 'Dus',
      status: 'RECEIVED',
      documents: const [
        LogisticsDocumentModel(id: 'ld-1', logisticsItemId: 'log-1', documentType: 'item_photo', driveFileId: 'drv-l1'),
        LogisticsDocumentModel(id: 'ld-2', logisticsItemId: 'log-1', documentType: 'receipt', driveFileId: 'drv-l2', note: 'Barang diterima dalam kondisi baik.'),
      ],
    ),
    LogisticsItemModel(id: 'log-2', eventId: 'evt-porseni', name: 'Banner', quantity: 3, unit: 'Buah', status: 'RECEIVED'),
    LogisticsItemModel(id: 'log-3', eventId: 'evt-porseni', name: 'Konsumsi Panitia', quantity: 20, unit: 'Pack', status: 'RECEIVED'),
    LogisticsItemModel(id: 'log-4', eventId: 'evt-porseni', name: 'Dekorasi Panggung', quantity: 1, unit: 'Set', status: 'PENDING'),
    LogisticsItemModel(id: 'log-5', eventId: 'evt-porseni', name: 'ATK', quantity: 1, unit: 'Paket', status: 'PENDING'),
  ];

  static LogisticsItemModel logisticsItemById(String id) =>
      logisticsItemsPorseni.firstWhere((e) => e.id == id);
}
