import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import '../events/events_page.dart';
import 'widgets/stat_card.dart';

/// Layout desktop — sesuai layar atas image.png
/// (sidebar di AppShell, konten: header, 4 kartu statistik,
/// grafik arus kas, aktivitas terbaru, banner pengingat).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 24),
          const _StatsRow(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 3, child: _CashFlowCard()),
              SizedBox(width: 20),
              Expanded(flex: 2, child: _ActivityCard()),
            ],
          ),
          const SizedBox(height: 20),
          const _ReminderBanner(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${MockData.currentUser.name} ',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(MockData.currentUser.role,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.text),
            ),
            const Positioned(
              right: 10,
              top: 10,
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.red),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.navy,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_down)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatCard(
            label: 'Saldo Kas',
            value: MockData.saldoKas,
            caption: 'Total saldo saat ini',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.green,
            iconBg: Color(0xFFE8F8EF),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Pemasukan',
            value: MockData.totalPemasukan,
            caption: 'Total pemasukan',
            icon: Icons.arrow_circle_down_outlined,
            iconColor: AppColors.green,
            iconBg: Color(0xFFE8F8EF),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Pengeluaran',
            value: MockData.totalPengeluaran,
            caption: 'Total pengeluaran',
            icon: Icons.arrow_circle_up_outlined,
            iconColor: AppColors.red,
            iconBg: Color(0xFFFDECEC),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Event Aktif',
            value: MockData.eventAktifCount,
            caption: 'Sedang berlangsung',
            icon: Icons.event_available_outlined,
            iconColor: AppColors.purple,
            iconBg: Color(0xFFF3EAFD),
            isCurrency: false,
          ),
        ),
      ],
    );
  }
}

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard();

  @override
  Widget build(BuildContext context) {
    final points = MockData.cashFlow30;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Ringkasan Arus Kas',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('30 Hari Terakhir',
                          style: TextStyle(fontSize: 12)),
                      Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _Legend(color: AppColors.green, label: 'Pemasukan'),
                SizedBox(width: 20),
                _Legend(color: AppColors.red, label: 'Pengeluaran'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 4000000,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000000,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1000000,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          '${(v / 1000000).toStringAsFixed(0)} jt',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i % 7 != 6 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final labels = MockData.cashFlowLabels;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[(i ~/ 7).clamp(0, labels.length - 1)],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    _line(points
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                        .toList(), AppColors.green),
                    _line(points
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                        .toList(), AppColors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.06),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final activities = MockData.activities;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Aktivitas Terbaru',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final a in activities.take(4))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _ActivityTile(activity: a),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isIncome = activity.type == TxType.income;
    final color = isIncome ? AppColors.green : AppColors.red;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(activity.eventName,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${formatRupiah(activity.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(formatDate(activity.date),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.amber,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengingat',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'RAB PORSENI 2024 menunggu persetujuan pembina.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout mobile — sesuai layar "Halo, Azmi" pada image.png
// ---------------------------------------------------------------------------

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = MockData.events.where((e) => e.status == EvStatus.active);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, ${MockData.currentUser.name} 👋',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(MockData.currentUser.role,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications_outlined, color: AppColors.text),
            ],
          ),
          const SizedBox(height: 20),
          // Kartu Saldo Kas (navy)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Saldo Kas',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: Colors.white54, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(formatRupiah(MockData.saldoKas),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Total saldo saat ini',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MobileFlowCard(
                  label: 'Pemasukan',
                  value: MockData.totalPemasukan,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MobileFlowCard(
                  label: 'Pengeluaran',
                  value: MockData.totalPengeluaran,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text('Event Aktif',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventsPage()),
                ),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          for (final e in events) ...[
            EventCard(event: e),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _MobileFlowCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _MobileFlowCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.text)),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(formatRupiah(value),
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }
}
