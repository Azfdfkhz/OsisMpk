import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';

const _categoryIconMap = {
  'Konsumsi': Icons.local_cafe_rounded,
  'Dana Sponsor': Icons.card_giftcard_rounded,
  'Dekorasi': Icons.style_rounded,
  'ATK': Icons.edit_note_rounded,
  'Sewa Peralatan': Icons.speaker_rounded,
  'Dana Kelas': Icons.groups_rounded,
};

/// Baris pada daftar transaksi, mengikuti tampilan "Transaksi" pada desain.
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppColors.success : AppColors.danger;
    final icon = _categoryIconMap[transaction.categoryName] ?? Icons.receipt_long_rounded;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(transaction.description ?? '-', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(transaction.eventName ?? '-', style: AppTextStyles.caption),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            CurrencyFormatter.formatSigned(transaction.amount, isIncome: transaction.isIncome),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(DateFormatter.short(transaction.transactionDate), style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
