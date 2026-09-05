import '../models/dashboard_models.dart';
import '../services/mock_data.dart';

/// Repository dashboard. Saat ini membaca dari [MockData]; pada integrasi
/// nyata, ganti isi method di bawah dengan query ke view Supabase:
/// v_dashboard_summary, v_cash_flow_daily (schema baris 641-672),
/// dan tabel transactions/notifications untuk aktivitas & pengingat.
class DashboardRepository {
  Future<DashboardSummary> getSummary() async {
    return MockData.dashboardSummary;
  }

  Future<List<CashFlowPoint>> getCashFlow({int days = 30}) async {
    return MockData.cashFlow;
  }

  Future<List<ActivityItem>> getRecentActivities({int limit = 4}) async {
    return MockData.activities.take(limit).toList();
  }

  Future<ReminderItem?> getReminder() async {
    return MockData.reminder;
  }
}
