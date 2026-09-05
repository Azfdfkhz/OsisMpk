import '../models/logistics_item_model.dart';
import '../services/mock_data.dart';

/// Repository logistik. Ganti dengan query ke tabel `logistics_items`
/// dan `logistics_documents` (schema baris 288-314 / README bagian 20-21)
/// saat integrasi Supabase dilakukan. Modul ini sengaja dipisah dari
/// data keuangan sensitif (README bagian 20).
class LogisticsRepository {
  Future<List<LogisticsItemModel>> getItemsForEvent(String eventId) async {
    return MockData.logisticsItemsPorseni.where((e) => e.eventId == eventId).toList();
  }

  Future<LogisticsItemModel> getItemById(String id) async {
    return MockData.logisticsItemById(id);
  }
}
