/// Mirror dari tabel `events` + view `v_event_summary`
/// (schema baris 179-193 & 674-701 / README bagian 14).
///
/// status mengikuti enum event_status: DRAFT, ACTIVE, COMPLETED, CANCELLED
/// -- dipetakan ke tab "Draft / Aktif / Selesai" pada desain.
class EventModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalBudget; // dari v_event_summary.total_budget
  final double realisasi; // dari v_event_summary.realisasi (total pengeluaran)
  final double pemasukan; // dari v_event_summary.pemasukan
  final String status;

  const EventModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.startDate,
    this.endDate,
    required this.totalBudget,
    required this.realisasi,
    required this.pemasukan,
    required this.status,
  });

  /// persentase_realisasi dari view (dibulatkan untuk progress bar kartu event).
  double get progressPercent {
    if (totalBudget <= 0) return 0;
    final p = (realisasi / totalBudget) * 100;
    // num.clamp() returns num, bukan double -- perlu di-cast eksplisit
    // agar tetap konsisten dengan tipe kembalian getter ini.
    return p.clamp(0, 100).toDouble();
  }

  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED';
  bool get isDraft => status == 'DRAFT';

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      totalBudget: (map['total_budget'] as num? ?? 0).toDouble(),
      realisasi: (map['realisasi'] as num? ?? 0).toDouble(),
      pemasukan: (map['pemasukan'] as num? ?? 0).toDouble(),
      status: map['status'] as String,
    );
  }
}
