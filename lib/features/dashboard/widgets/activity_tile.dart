import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/dashboard_models.dart';

/// Baris pada daftar "Aktivitas Terbaru" di dashboard.
class ActivityTile extends StatelessWidget {
  final ActivityItem activity;
  final VoidCallback? onTap;

  const ActivityTile({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activity.isIncome ? AppColors.success : AppColors.danger;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.12),
        child: Icon(
          activity.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: color,
        ),
      ),
      title: Text(activity.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(activity.subtitle, style: AppTextStyles.caption),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            CurrencyFormatter.formatSigned(activity.amount, isIncome: activity.isIncome),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(DateFormatter.short(activity.date), style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
