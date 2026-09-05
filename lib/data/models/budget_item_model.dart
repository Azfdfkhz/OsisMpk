/// Mirror dari tabel `budget_items` (schema baris 222-234 / README bagian 15).
/// total = quantity * estimated_price (generated column di database).
class BudgetItemModel {
  final String id;
  final String budgetId;
  final String description; // Konsumsi, Dekorasi, Hadiah, ATK, dst
  final double quantity;
  final String? unit;
  final double estimatedPrice;

  const BudgetItemModel({
    required this.id,
    required this.budgetId,
    required this.description,
    required this.quantity,
    this.unit,
    required this.estimatedPrice,
  });

  double get total => quantity * estimatedPrice;

  factory BudgetItemModel.fromMap(Map<String, dynamic> map) {
    return BudgetItemModel(
      id: map['id'] as String,
      budgetId: map['budget_id'] as String,
      description: map['description'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String?,
      estimatedPrice: (map['estimated_price'] as num).toDouble(),
    );
  }
}
