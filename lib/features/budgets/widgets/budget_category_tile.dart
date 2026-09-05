import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/budget_model.dart';

/// Baris rincian anggaran per kategori pada "RAB - Ringkasan"
/// (mis. "Konsumsi Rp 2.500.000 / Rp 4.000.000 - 62.5%").
class BudgetCategoryTile extends StatelessWidget {
  final BudgetCategoryBreakdown item;

  const BudgetCategoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final over = item.realisasiKategori > item.anggaranKategori;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.categoryName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text('${item.percent.toStringAsFixed(1)}%', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${CurrencyFormatter.format(item.realisasiKategori)} / ${CurrencyFormatter.format(item.anggaranKategori)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (item.percent / 100).clamp(0, 1).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(over ? AppColors.danger : AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
