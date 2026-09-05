import 'budget_item_model.dart';

/// Mirror dari tabel `budgets` (schema baris 206-220 / README bagian 15).
/// status mengikuti workflow_status: DRAFT, SUBMITTED, REVIEW, APPROVED, REJECTED.
class BudgetModel {
  final String id;
  final String eventId;
  final String name; // "RAB PORSENI 2024"
  final double total;
  final String status;
  final List<BudgetItemModel> items;

  const BudgetModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.total,
    required this.status,
    this.items = const [],
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      name: map['name'] as String,
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}

/// Mirror dari view `v_budget_category_breakdown` (schema baris 703-721).
/// Dipakai pada layar "RAB - Ringkasan" untuk rincian per kategori.
class BudgetCategoryBreakdown {
  final String categoryName;
  final double anggaranKategori;
  final double realisasiKategori;

  const BudgetCategoryBreakdown({
    required this.categoryName,
    required this.anggaranKategori,
    required this.realisasiKategori,
  });

  double get percent {
    if (anggaranKategori <= 0) return 0;
    // num.clamp() returns num, bukan double -- perlu di-cast eksplisit.
    return (realisasiKategori / anggaranKategori * 100).clamp(0, 100).toDouble();
  }
}
