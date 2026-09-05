import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../logistics/pages/logistics_page.dart';
import '../widgets/budget_category_tile.dart';

/// Halaman "RAB - [Nama Event]" dengan tab Ringkasan / Rincian / Persetujuan,
/// sesuai desain mobile.
class RabPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const RabPage({super.key, required this.eventId, required this.eventName});

  @override
  ConsumerState<RabPage> createState() => _RabPageState();
}

class _RabPageState extends ConsumerState<RabPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetForEventProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('RAB - ${widget.eventName}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LogisticsPage(eventId: widget.eventId, eventName: widget.eventName),
                ),
              );
            },
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Logistik',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.navy,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Rincian'),
            Tab(text: 'Persetujuan'),
          ],
        ),
      ),
      body: budgetAsync.when(
        data: (budget) => TabBarView(
          controller: _tabController,
          children: [
            _RingkasanTab(eventId: widget.eventId, budgetId: budget.id, total: budget.total),
            _RincianTab(items: budget.items),
            _PersetujuanTab(status: budget.status, belumDibuat: budget.items.isEmpty && budget.total == 0),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat RAB: $e')),
      ),
    );
  }
}

class _RingkasanTab extends ConsumerWidget {
  final String eventId;
  final String budgetId;
  final double total;

  const _RingkasanTab({required this.eventId, required this.budgetId, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(budgetBreakdownProvider(budgetId));

    return breakdownAsync.when(
      data: (items) {
        final realisasi = items.fold<double>(0, (sum, i) => sum + i.realisasiKategori);
        final sisa = total - realisasi;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Total Anggaran', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(CurrencyFormatter.format(total), style: AppTextStyles.h1.copyWith(fontSize: 22)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(label: 'Realisasi', value: CurrencyFormatter.format(realisasi), color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(label: 'Sisa Anggaran', value: CurrencyFormatter.format(sisa), color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? (realisasi / total).clamp(0, 1).toDouble() : 0.0,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
              ),
            ),
            const SizedBox(height: 24),
            Text('Kategori', style: AppTextStyles.h2.copyWith(fontSize: 15)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Belum ada rincian kategori untuk event ini.'),
                      )
                    : Column(
                        children: [
                          for (final item in items) ...[
                            BudgetCategoryTile(item: item),
                            if (item != items.last) const Divider(height: 1),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat rincian: $e')),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _RincianTab extends StatelessWidget {
  final List<dynamic> items; // List<BudgetItemModel>

  const _RincianTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada rincian item RAB.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.description, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('${item.quantity.toStringAsFixed(0)} ${item.unit ?? ''} x ${CurrencyFormatter.format(item.estimatedPrice)}'),
          trailing: Text(CurrencyFormatter.format(item.total), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        );
      },
    );
  }
}

class _PersetujuanTab extends StatelessWidget {
  final String status;
  final bool belumDibuat;

  const _PersetujuanTab({required this.status, this.belumDibuat = false});

  @override
  Widget build(BuildContext context) {
    final approved = status == 'APPROVED';
    final icon = belumDibuat
        ? Icons.edit_document
        : (approved ? Icons.verified_outlined : Icons.hourglass_top_outlined);
    final color = belumDibuat
        ? AppColors.textSecondary
        : (approved ? AppColors.success : AppColors.warning);
    final message = belumDibuat
        ? 'RAB belum dibuat untuk event ini'
        : (approved ? 'RAB sudah disetujui pembina' : 'RAB menunggu persetujuan pembina');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!belumDibuat) ...[
              const SizedBox(height: 4),
              Text('Status saat ini: $status', style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
