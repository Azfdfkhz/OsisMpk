/// Mirror dari view `v_dashboard_summary` (schema baris 641-661).
class DashboardSummary {
  final double totalSaldoKas;
  final double totalPemasukan;
  final double totalPengeluaran;
  final int eventAktif;

  const DashboardSummary({
    required this.totalSaldoKas,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.eventAktif,
  });
}

/// Satu titik pada grafik "Ringkasan Arus Kas", dari view `v_cash_flow_daily`
/// (schema baris 663-672).
class CashFlowPoint {
  final DateTime tanggal;
  final double pemasukan;
  final double pengeluaran;

  const CashFlowPoint({
    required this.tanggal,
    required this.pemasukan,
    required this.pengeluaran,
  });
}

/// Baris pada daftar "Aktivitas Terbaru" di dashboard — diringkas dari
/// tabel `transactions` (income/expense terbaru).
class ActivityItem {
  final String title;
  final String subtitle; // nama event
  final double amount;
  final bool isIncome;
  final DateTime date;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

/// Kartu "Pengingat" di dashboard — mis. RAB yang menunggu persetujuan
/// (tabel `approval_requests`, status PENDING).
class ReminderItem {
  final String title;
  final String description;

  const ReminderItem({required this.title, required this.description});
}
