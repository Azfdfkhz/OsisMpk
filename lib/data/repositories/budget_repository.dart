import '../models/budget_model.dart';
import '../services/mock_data.dart';

/// Repository RAB. Ganti dengan query ke tabel `budgets`/`budget_items`
/// dan view `v_budget_category_breakdown` (schema baris 206-234, 703-721
/// / README bagian 15) saat integrasi Supabase dilakukan.
class BudgetRepository {
  Future<BudgetModel> getBudgetForEvent(String eventId) async {
    // Mock hanya menyediakan data rinci untuk PORSENI 2024. Event lain
    // dikembalikan sebagai RAB kosong (belum dibuat) alih-alih ikut
    // menampilkan angka PORSENI, supaya tidak menyesatkan saat testing.
    if (eventId == MockData.budgetPorseni.eventId) {
      return MockData.budgetPorseni;
    }
    return BudgetModel(
      id: 'bud-$eventId',
      eventId: eventId,
      name: 'RAB belum dibuat',
      total: 0,
      status: 'DRAFT',
      items: const [],
    );
  }

  Future<List<BudgetCategoryBreakdown>> getCategoryBreakdown(String budgetId) async {
    if (budgetId == MockData.budgetPorseni.id) {
      return MockData.budgetBreakdownPorseni;
    }
    return const [];
  }
}
