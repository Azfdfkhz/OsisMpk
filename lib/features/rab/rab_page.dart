import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';

/// RAB Event — tab Ringkasan / Rincian / Persetujuan (desain image.png).
class RABPage extends StatelessWidget {
  final EventItem event;
  const RABPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('RAB - ${event.name}'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Rincian'),
              Tab(text: 'Persetujuan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RingkasanTab(event: event),
            const _RincianTab(),
            const _PersetujuanTab(),
          ],
        ),
      ),
    );
  }
}

class _RingkasanTab extends StatelessWidget {
  final EventItem event;
  const _RingkasanTab({required this.event});

  @override
  Widget build(BuildContext context) {
    const total = MockData.rabTotal;
    const realisasi = MockData.rabRealisasi;
    final percent = realisasi / total * 100;
    final sisa = total - realisasi;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Total Anggaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text(formatRupiah(total),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('Realisasi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Spacer(),
            Text('${percent.toStringAsFixed(1).replaceAll('.', ',')}%',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Text(formatRupiah(realisasi),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.green),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('Sisa Anggaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Spacer(),
            Text(formatRupiah(sisa),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final c in MockData.rabCategories) ...[
          _CategoryRow(category: c),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final RabCategory category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${formatRupiah(category.used)} / ${formatRupiah(category.budget)}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            Text(
              formatPercent(category.percent),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (category.percent / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _RincianTab extends StatelessWidget {
  const _RincianTab();

  @override
  Widget build(BuildContext context) {
    final total = MockData.rabItems.fold<int>(0, (sum, i) => sum + i.total);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header tabel (format Google Sheets, README bagian 16)
        const _TableRow(
          cells: ['No', 'Uraian', 'Volume', 'Satuan', 'Harga', 'Jumlah'],
          isHeader: true,
        ),
        for (var i = 0; i < MockData.rabItems.length; i++)
          _TableRow(
            cells: [
              '${i + 1}',
              MockData.rabItems[i].description,
              '${MockData.rabItems[i].qty}',
              MockData.rabItems[i].unit,
              formatRupiah(MockData.rabItems[i].price),
              formatRupiah(MockData.rabItems[i].total),
            ],
          ),
        const Divider(height: 24),
        Row(
          children: [
            const Text('TOTAL',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const Spacer(),
            Text(formatRupiah(total),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.table_view_outlined, size: 18),
          label: const Text('Export ke Google Sheets'),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;
  const _TableRow({required this.cells, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
      fontSize: 12,
      color: isHeader ? AppColors.text : AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(cells[0], style: style)),
          Expanded(flex: 3, child: Text(cells[1], style: style)),
          Expanded(flex: 2, child: Text(cells[2], style: style)),
          Expanded(flex: 2, child: Text(cells[3], style: style)),
          Expanded(flex: 3, child: Text(cells[4], style: style, textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text(cells[5], style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _PersetujuanTab extends StatelessWidget {
  const _PersetujuanTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.hourglass_top_outlined,
                    color: AppColors.amber, size: 28),
                const SizedBox(height: 12),
                Text('Menunggu Persetujuan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'RAB ini menunggu persetujuan pembina. '
                  'Anda akan mendapat notifikasi setelah diputuskan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _decide(context, 'disetujui'),
                        child: const Text('Setujui'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _decide(context, 'ditolak'),
                        child: const Text('Tolak'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _decide(BuildContext context, String result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('RAB $result (demo). Tercatat di audit log (README bagian 25).')),
    );
  }
}
