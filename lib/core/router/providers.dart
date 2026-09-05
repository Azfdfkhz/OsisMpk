import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/budget_model.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/models/event_model.dart';
import '../../data/models/logistics_item_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/logistics_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/services/mock_data.dart';

// ---------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------
final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());
final eventRepositoryProvider = Provider((ref) => EventRepository());
final transactionRepositoryProvider = Provider((ref) => TransactionRepository());
final budgetRepositoryProvider = Provider((ref) => BudgetRepository());
final logisticsRepositoryProvider = Provider((ref) => LogisticsRepository());

// ---------------------------------------------------------------------
// Current user (README bagian 4-5: hasil Google OAuth + Supabase Auth)
// ---------------------------------------------------------------------
final currentUserProvider = Provider((ref) => MockData.currentUser);

// ---------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).getSummary();
});

final cashFlowProvider = FutureProvider<List<CashFlowPoint>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getCashFlow();
});

final recentActivitiesProvider = FutureProvider<List<ActivityItem>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getRecentActivities();
});

final reminderProvider = FutureProvider<ReminderItem?>((ref) {
  return ref.watch(dashboardRepositoryProvider).getReminder();
});

// ---------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------
final eventStatusFilterProvider = StateProvider<String>((ref) => 'ACTIVE');

final eventListProvider = FutureProvider<List<EventModel>>((ref) {
  final filter = ref.watch(eventStatusFilterProvider);
  return ref.watch(eventRepositoryProvider).getEvents(statusFilter: filter);
});

// ---------------------------------------------------------------------
// Transactions
// ---------------------------------------------------------------------
final transactionTypeFilterProvider = StateProvider<String>((ref) => 'ALL');

final transactionListProvider = FutureProvider<List<TransactionModel>>((ref) {
  final filter = ref.watch(transactionTypeFilterProvider);
  return ref.watch(transactionRepositoryProvider).getTransactions(typeFilter: filter);
});

final transactionByIdProvider =
    FutureProvider.family<TransactionModel, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).getTransactionById(id);
});

// ---------------------------------------------------------------------
// Budget / RAB
// ---------------------------------------------------------------------
final budgetForEventProvider =
    FutureProvider.family<BudgetModel, String>((ref, eventId) {
  return ref.watch(budgetRepositoryProvider).getBudgetForEvent(eventId);
});

final budgetBreakdownProvider =
    FutureProvider.family<List<BudgetCategoryBreakdown>, String>((ref, budgetId) {
  return ref.watch(budgetRepositoryProvider).getCategoryBreakdown(budgetId);
});

// ---------------------------------------------------------------------
// Logistics
// ---------------------------------------------------------------------
final logisticsItemsProvider =
    FutureProvider.family<List<LogisticsItemModel>, String>((ref, eventId) {
  return ref.watch(logisticsRepositoryProvider).getItemsForEvent(eventId);
});

final logisticsItemByIdProvider =
    FutureProvider.family<LogisticsItemModel, String>((ref, id) {
  return ref.watch(logisticsRepositoryProvider).getItemById(id);
});

// ---------------------------------------------------------------------
// Bottom navigation index untuk MainShell
// ---------------------------------------------------------------------
final mainNavIndexProvider = StateProvider<int>((ref) => 0);
