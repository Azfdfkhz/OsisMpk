import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_page.dart';

/// Halaman "Transaksi" dengan tab Semua / Pemasukan / Pengeluaran
/// dan tombol "+ Transaksi" sesuai desain.
class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  static const _tabs = [
    ('Semua', 'ALL'),
    ('Pemasukan', 'income'),
    ('Pengeluaran', 'expense'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionTypeFilterProvider);
    final txAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Transaksi', style: AppTextStyles.h2),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.navy,
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final tab in _tabs) ...[
                  ChoiceChip(
                    label: Text(tab.$1),
                    selected: filter == tab.$2,
                    selectedColor: AppColors.navy,
                    labelStyle: TextStyle(
                      color: filter == tab.$2 ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    onSelected: (_) => ref.read(transactionTypeFilterProvider.notifier).state = tab.$2,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: txAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final trx = list[index];
                    return TransactionTile(
                      transaction: trx,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TransactionDetailPage(transactionId: trx.id)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat transaksi: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
