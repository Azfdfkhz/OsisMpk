import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/logistics_item_tile.dart';
import 'logistics_documentation_page.dart';

/// Halaman "Logistik - [Nama Event]" dengan tab Daftar Barang / Dokumentasi,
/// sesuai desain mobile.
class LogisticsPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const LogisticsPage({super.key, required this.eventId, required this.eventName});

  @override
  ConsumerState<LogisticsPage> createState() => _LogisticsPageState();
}

class _LogisticsPageState extends ConsumerState<LogisticsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(logisticsItemsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Logistik - ${widget.eventName}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.navy,
          tabs: const [
            Tab(text: 'Daftar Barang'),
            Tab(text: 'Dokumentasi'),
          ],
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          final total = items.length;
          final selesai = items.where((e) => e.isReceived).length;

          return TabBarView(
            controller: _tabController,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        _CountBox(label: 'Total Barang', value: '$total Item'),
                        const SizedBox(width: 24),
                        _CountBox(label: 'Selesai', value: '$selesai Item'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return LogisticsItemTile(
                          item: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => LogisticsDocumentationPage(itemId: item.id)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.photo_library_outlined, color: AppColors.textSecondary),
                    title: Text(item.name),
                    subtitle: Text('${item.documents.length} dokumentasi'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LogisticsDocumentationPage(itemId: item.id)),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat logistik: $e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Tambah Barang'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  final String label;
  final String value;

  const _CountBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
