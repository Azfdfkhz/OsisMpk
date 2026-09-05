import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/activity_tile.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/summary_card.dart';

/// Halaman "Beranda" — meniru layar Dashboard & mobile "Halo, Azmi"
/// pada desain OSIS Finance.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final cashFlowAsync = ref.watch(cashFlowProvider);
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final reminderAsync = ref.watch(reminderProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, ${user.fullName} 👋', style: AppTextStyles.h2),
                  Text(user.roleName, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const CircleAvatar(radius: 18, backgroundColor: AppColors.navy, child: Icon(Icons.person, color: Colors.white, size: 18)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(cashFlowProvider);
          ref.invalidate(recentActivitiesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  // Kartu "Saldo Kas" besar sesuai versi mobile pada desain
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo Kas', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(summary.totalSaldoKas),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        const Text('Total saldo saat ini', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Pemasukan',
                          caption: 'Total pemasukan',
                          value: summary.totalPemasukan,
                          icon: Icons.arrow_upward,
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Pengeluaran',
                          caption: 'Total pengeluaran',
                          value: summary.totalPengeluaran,
                          icon: Icons.arrow_downward,
                          iconColor: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SummaryCard(
                    label: 'Event Aktif',
                    caption: 'Sedang berlangsung',
                    value: summary.eventAktif,
                    icon: Icons.event_available_outlined,
                    iconColor: AppColors.purple,
                    isCurrency: false,
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Gagal memuat ringkasan: $e'),
            ),

            const SizedBox(height: 20),

            // Ringkasan Arus Kas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ringkasan Arus Kas', style: AppTextStyles.h2.copyWith(fontSize: 15)),
                        const Text('30 Hari Terakhir', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const CashFlowLegend(),
                    const SizedBox(height: 8),
                    cashFlowAsync.when(
                      data: (points) => CashFlowChart(points: points),
                      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text('Gagal memuat grafik: $e'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Aktivitas Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktivitas Terbaru', style: AppTextStyles.h2.copyWith(fontSize: 15)),
                TextButton(onPressed: () {}, child: const Text('Lihat semua')),
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: activitiesAsync.when(
                  data: (activities) => Column(
                    children: [
                      for (final a in activities) ...[
                        ActivityTile(activity: a),
                        if (a != activities.last) const Divider(height: 1),
                      ],
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Gagal memuat aktivitas: $e'),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pengingat
            reminderAsync.when(
              data: (reminder) {
                if (reminder == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reminder.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                            Text(reminder.description, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Lihat Detail')),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
