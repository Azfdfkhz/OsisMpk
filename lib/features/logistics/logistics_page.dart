import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import 'documentation_page.dart';

/// Logistik Event — tab Daftar Barang / Dokumentasi (desain image.png).
///
/// Catatan README bagian 20: Logistik TIDAK mengakses data keuangan
/// sensitif. Fokus: dokumentasi barang, foto nota, status penerimaan.
class LogisticsPage extends StatelessWidget {
  final EventItem event;
  const LogisticsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Logistik - ${event.name}'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Daftar Barang'),
              Tab(text: 'Dokumentasi'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Barang',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('12 Item',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selesai',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('8 Item',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: MockData.logisticsItems.length,
                    itemBuilder: (context, i) {
                      final item = MockData.logisticsItems[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LogisticsItemCard(item: item),
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      'Semua dokumentasi barang tampil di sini.\n'
                      'File fisik disimpan di Google Drive (README bagian 17).',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tambah Barang'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogisticsItemCard extends StatelessWidget {
  final LogisticsItem item;
  const LogisticsItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DocumentationPage(item: item)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${item.qty} ${item.unit}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.received
                      ? AppColors.green.withOpacity(0.12)
                      : AppColors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.received ? 'Diterima' : 'Belum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.received ? AppColors.green : AppColors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
