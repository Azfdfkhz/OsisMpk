import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';

/// Detail Transaksi (desain image.png): nominal, info transaksi,
/// dokumentasi bukti, tombol Bagikan / Ubah.
class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TxType.income;
    final color = isIncome ? AppColors.green : AppColors.red;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Detail Transaksi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${isIncome ? '+' : '-'}${formatRupiah(transaction.amount)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(transaction.title,
              style: Theme.of(context).textTheme.titleMedium),
          Text(transaction.eventName,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: formatDateTime(transaction.date),
          ),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: transaction.category,
          ),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Metode Pembayaran',
            value: transaction.paymentMethod,
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Dibuat oleh',
            value:
                '${MockData.currentUser.name} (${MockData.currentUser.role})',
          ),
          _InfoRow(
            icon: Icons.event_note_outlined,
            label: 'Dicatat untuk',
            value: transaction.eventName,
          ),
          if (transaction.note.isNotEmpty)
            _InfoRow(
              icon: Icons.notes_outlined,
              label: 'Catatan',
              value: transaction.note,
            ),
          const SizedBox(height: 24),
          if (transaction.docCount > 0) ...[
            Text('Dokumentasi',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  Expanded(
                    child: _DocThumbnail(
                      more: i == 2 ? transaction.docCount - 2 : 0,
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 28),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share_outlined, size: 18),
                  label: const Text('Bagikan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Ubah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DocThumbnail extends StatelessWidget {
  final int more;
  const _DocThumbnail({this.more = 0});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Center(
              child: Icon(Icons.image_outlined,
                  color: AppColors.textSecondary, size: 28),
            ),
            if (more > 0)
              Container(
                color: Colors.black38,
                child: Center(
                  child: Text(
                    '+$more',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
