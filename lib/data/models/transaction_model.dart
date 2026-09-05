import 'document_model.dart';

/// Mirror dari tabel `transactions` (schema baris 240-263 / README bagian 12-13).
/// type: income | expense | transfer | adjustment (transaction_type)
/// status: DRAFT | SUBMITTED | REVIEW | APPROVED | REJECTED | VOID | COMPLETED
class TransactionModel {
  final String id;
  final String? eventId;
  final String? eventName; // denormalized untuk kebutuhan tampilan list
  final String? categoryId;
  final String? categoryName;
  final String type;
  final double amount;
  final String? description;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String status;
  final String? createdByName;
  final List<DocumentModel> documents;
  final String? note;

  const TransactionModel({
    required this.id,
    this.eventId,
    this.eventName,
    this.categoryId,
    this.categoryName,
    required this.type,
    required this.amount,
    this.description,
    this.paymentMethod,
    required this.transactionDate,
    required this.status,
    this.createdByName,
    this.documents = const [],
    this.note,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String?,
      eventName: map['event_name'] as String?,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] as String?,
      transactionDate: DateTime.parse(map['transaction_date']),
      status: map['status'] as String,
      createdByName: map['created_by_name'] as String?,
      note: map['note'] as String?,
    );
  }
}
