import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/event_model.dart';

const _iconMap = {
  'star': Icons.star_rounded,
  'trending_up': Icons.trending_up_rounded,
  'directions_bus': Icons.directions_bus_rounded,
  'groups': Icons.groups_rounded,
  'menu_book': Icons.menu_book_rounded,
};

/// Kartu event pada tab "Event", menampilkan progress bar & sisa budget
/// sesuai desain (mis. "PORSENI 2024 - 75% - Budget: Rp 10.000.000").
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[event.icon] ?? Icons.event_note_rounded;
    final progress = event.progressPercent / 100;
    final dateLabel = event.startDate != null
        ? '${DateFormatter.short(event.startDate!)}'
            '${event.endDate != null ? ' - ${DateFormatter.short(event.endDate!)}' : ''}'
        : (event.isActive ? 'Berlangsung' : '-');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.blue.withOpacity(0.12),
                child: Icon(icon, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(event.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Text('${event.progressPercent.toStringAsFixed(0)}%',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(dateLabel, style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1).toDouble(),
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.success),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Budget: ${CurrencyFormatter.format(event.totalBudget)}', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
