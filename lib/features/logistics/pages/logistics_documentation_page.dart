import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

const _docTypeLabels = {
  'item_photo': 'Foto Barang',
  'receipt': 'Nota',
  'delivery': 'Penerimaan',
  'condition': 'Kondisi',
  'other': 'Lainnya',
};

const _docTypeIcons = {
  'item_photo': Icons.photo_camera_outlined,
  'receipt': Icons.receipt_long_outlined,
  'delivery': Icons.local_shipping_outlined,
  'condition': Icons.fact_check_outlined,
  'other': Icons.attach_file_outlined,
};

/// Jenis dokumentasi yang ditampilkan pada baris pintasan "Jenis Dokumentasi"
/// (sesuai desain: Foto Barang / Nota / Penerimaan / Lainnya). Tipe lain
/// (mis. 'condition') tetap didukung skema & tetap dirender bila sudah ada
/// datanya, hanya tidak ikut tombol pintasan ini.
const _quickDocTypes = ['item_photo', 'receipt', 'delivery', 'other'];

/// Halaman "Dokumentasi Barang" sesuai desain: nama & qty barang, jenis
/// dokumentasi (chip ikon), grid foto dokumentasi, catatan, dan tombol
/// "Simpan Dokumentasi".
class LogisticsDocumentationPage extends ConsumerWidget {
  final String itemId;

  const LogisticsDocumentationPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(logisticsItemByIdProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dokumentasi Barang')),
      body: itemAsync.when(
        data: (item) {
          final note = item.documents.isNotEmpty
              ? item.documents.map((d) => d.note).firstWhere((n) => n != null, orElse: () => null)
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.blue.withOpacity(0.12),
                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.blue),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.h2.copyWith(fontSize: 16)),
                      Text(item.quantityLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Jenis Dokumentasi', style: AppTextStyles.label),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _quickDocTypes.map((key) {
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.background,
                          child: Icon(_docTypeIcons[key], color: AppColors.navy, size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _docTypeLabels[key]!,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Dokumentasi (${item.documents.length})', style: AppTextStyles.label),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: item.documents.length + 1,
                itemBuilder: (context, index) {
                  if (index == item.documents.length) {
                    return DottedAddTile(onTap: () {});
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
              if (note != null) ...[
                const SizedBox(height: 20),
                Text('Catatan', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Text(note, style: AppTextStyles.body),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Simpan Dokumentasi'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat dokumentasi: $e')),
      ),
    );
  }
}

class DottedAddTile extends StatelessWidget {
  final VoidCallback onTap;
  const DottedAddTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.add, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
