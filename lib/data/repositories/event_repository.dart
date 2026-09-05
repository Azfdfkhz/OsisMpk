import '../models/event_model.dart';
import '../services/mock_data.dart';

/// Repository event. Ganti dengan query ke tabel `events` + view
/// `v_event_summary` (schema baris 179-193, 674-701 / README bagian 14)
/// saat integrasi Supabase dilakukan.
class EventRepository {
  Future<List<EventModel>> getEvents({String? statusFilter}) async {
    if (statusFilter == null || statusFilter == 'ALL') {
      return MockData.events;
    }
    return MockData.events.where((e) => e.status == statusFilter).toList();
  }

  Future<EventModel> getEventById(String id) async {
    return MockData.eventById(id);
  }
}
