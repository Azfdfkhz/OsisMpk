import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import 'transaction_detail_page.dart';

/// Daftar Transaksi — chip Semua / Pemasukan / Pengeluaran + FAB "+ Transaksi".
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _filter = 0; // 0 Semua, 1 Pemasukan, 2 Pengeluaran

  List<TransactionModel> get _filtered {
    switch (_filter) {
      case 1:
        return MockData.transactions
            .where((t) => t.type == TxType.income)
            .toList();
      case 2:
        return MockData.transactions
            .where((t) => t.type == TxType.expense)
            .toList();
      default:
        return MockData.transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua', 'Pemasukan', 'Pengeluaran'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.search, color: AppColors.text),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.tune, color: AppColors.text),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < filters.length; i++)
                    ChoiceChip(
                      label: Text(filters[i]),
                      selected: _filter == i,
                      onSelected: (_) => setState(() => _filter = i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TransactionTile(transaction: _filtered[i]),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TxType.income;
    final color = isIncome ? AppColors.green : AppColors.red;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(transaction: transaction),
          ),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
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
                    Text(transaction.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(transaction.eventName,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${formatRupiah(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
