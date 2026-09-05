import '../models/transaction_model.dart';
import '../services/mock_data.dart';

/// Repository transaksi. Ganti dengan query ke tabel `transactions`
/// (schema baris 240-263 / README bagian 12-13) saat integrasi Supabase
/// dilakukan. Insert/update harus tetap melalui RLS + fn_has_permission
/// agar keamanan tetap ditegakkan di database (README bagian 10).
class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({String? typeFilter}) async {
    if (typeFilter == null || typeFilter == 'ALL') {
      return MockData.transactions;
    }
    return MockData.transactions.where((t) => t.type == typeFilter).toList();
  }

  Future<TransactionModel> getTransactionById(String id) async {
    return MockData.transactions.firstWhere((t) => t.id == id);
  }

  Future<List<TransactionModel>> getTransactionsForEvent(String eventId) async {
    return MockData.transactionsForEvent(eventId);
  }
}
