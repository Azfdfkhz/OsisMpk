import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/logistics_item_model.dart';

const _logisticsIconMap = {
  'Air Mineral': Icons.local_drink_outlined,
  'Banner': Icons.branding_watermark_outlined,
  'Konsumsi Panitia': Icons.fastfood_outlined,
  'Dekorasi Panggung': Icons.celebration_outlined,
  'ATK': Icons.edit_note_outlined,
};

/// Baris barang pada "Logistik - Daftar Barang", dengan badge
/// "Diterima" / "Belum" sesuai desain.
class LogisticsItemTile extends StatelessWidget {
  final LogisticsItemModel item;
  final VoidCallback? onTap;

  const LogisticsItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _logisticsIconMap[item.name] ?? Icons.inventory_2_outlined;
    final badgeColor = item.isReceived ? AppColors.success : AppColors.warning;
    final badgeLabel = item.isReceived ? 'Diterima' : 'Belum';

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: badgeColor.withOpacity(0.12),
        child: Icon(icon, size: 16, color: badgeColor),
      ),
      title: Text(item.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(item.quantityLabel, style: AppTextStyles.caption),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(badgeLabel, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
