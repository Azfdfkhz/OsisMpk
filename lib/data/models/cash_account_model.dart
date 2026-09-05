/// Mirror dari tabel `cash_accounts` (schema baris 153-162).
class CashAccountModel {
  final String id;
  final String name;
  final double initialBalance;
  final double currentBalance;
  final bool isActive;

  const CashAccountModel({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.currentBalance,
    this.isActive = true,
  });

  factory CashAccountModel.fromMap(Map<String, dynamic> map) {
    return CashAccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      initialBalance: (map['initial_balance'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num).toDouble(),
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
