/// Mirror dari tabel `categories` (schema baris 164-173).
/// type: 'income' | 'expense' (enum category_type).
class CategoryModel {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  bool get isIncome => type == 'income';

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
    );
  }
}
