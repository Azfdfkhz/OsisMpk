import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';

/// Kartu ringkasan seperti "Saldo Kas / Pemasukan / Pengeluaran / Event Aktif"
/// pada bagian atas dashboard.
class SummaryCard extends StatelessWidget {
  final String label;
  final String caption;
  final num value;
  final IconData icon;
  final Color iconColor;
  final bool isCurrency;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.caption,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isCurrency = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(label, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconColor.withOpacity(0.12),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isCurrency ? CurrencyFormatter.format(value) : value.toString(),
              style: AppTextStyles.h1.copyWith(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(caption, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
