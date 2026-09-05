import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

/// Halaman "Detail Transaksi" sesuai desain: nominal besar, info tanggal /
/// kategori / metode pembayaran / dibuat oleh, dokumentasi bukti, dan
/// tombol Bagikan / Ubah.
class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionByIdProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: txAsync.when(
        data: (trx) {
          final color = trx.isIncome ? AppColors.success : AppColors.danger;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                CurrencyFormatter.formatSigned(trx.amount, isIncome: trx.isIncome),
                style: AppTextStyles.amountLarge.copyWith(color: color, fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(trx.description ?? '-', style: AppTextStyles.h2.copyWith(fontSize: 16)),
              Text(trx.eventName ?? '-', style: AppTextStyles.caption),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _DetailRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: DateFormatter.longWithTime(trx.transactionDate)),
                      const Divider(height: 1),
                      _DetailRow(icon: Icons.category_outlined, label: 'Kategori', value: trx.categoryName ?? '-'),
                      const Divider(height: 1),
                      _DetailRow(icon: Icons.payments_outlined, label: 'Metode Pembayaran', value: trx.paymentMethod ?? '-'),
                      const Divider(height: 1),
                      _DetailRow(icon: Icons.person_outline, label: 'Dibuat oleh', value: trx.createdByName ?? '-'),
                      const Divider(height: 1),
                      _DetailRow(icon: Icons.event_note_outlined, label: 'Dicatat untuk', value: trx.eventName ?? '-'),
                    ],
                  ),
                ),
              ),
              if (trx.note != null) ...[
                const SizedBox(height: 16),
                Text('Catatan', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Text(trx.note!, style: AppTextStyles.body),
              ],
              if (trx.documents.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Dokumentasi', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < trx.documents.length && i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _DocThumbnail(
                          // Tampilkan badge "+N" pada thumbnail ke-3 jika
                          // dokumentasi lebih banyak dari yang muat di layar
                          // (sesuai desain "Detail Transaksi").
                          extraCount: (i == 2 && trx.documents.length > 3)
                              ? trx.documents.length - 3
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Bagikan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Ubah'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat detail: $e')),
      ),
    );
  }
}

class _DocThumbnail extends StatelessWidget {
  /// Jika terisi, thumbnail menampilkan overlay gelap dengan teks "+N"
  /// (dokumentasi tambahan yang tidak muat ditampilkan).
  final int? extraCount;

  const _DocThumbnail({this.extraCount});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: AppColors.border,
              child: const Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary),
            ),
            if (extraCount != null && extraCount! > 0)
              Container(
                color: Colors.black.withOpacity(0.55),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
