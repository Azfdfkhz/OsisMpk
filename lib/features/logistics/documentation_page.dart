import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

/// Dokumentasi Barang (desain image.png):
/// pilih jenis dokumentasi, grid foto, catatan, simpan.
///
/// File fisik diunggah ke Google Drive; yang tersimpan di database
/// hanyalah metadata (drive_file_id) — README bagian 17 & 21.
class DocumentationPage extends StatefulWidget {
  final LogisticsItem item;
  const DocumentationPage({super.key, required this.item});

  @override
  State<DocumentationPage> createState() => _DocumentationPageState();
}

class _DocumentationPageState extends State<DocumentationPage> {
  int _docType = 0; // 0 Foto Barang, 1 Nota, 2 Penerimaan, 3 Lainnya
  final _noteController =
      TextEditingController(text: 'Barang diterima dalam kondisi baik.');
  final int _photoCount = 2;

  static const _docTypes = [
    (Icons.photo_camera_outlined, 'Foto Barang'),
    (Icons.receipt_long_outlined, 'Nota'),
    (Icons.local_shipping_outlined, 'Penerimaan'),
    (Icons.folder_outlined, 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dokumentasi Barang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info barang
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water_drop_outlined,
                        color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${widget.item.qty} ${widget.item.unit}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Jenis Dokumentasi',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _docTypes.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i < _docTypes.length - 1 ? 8 : 0),
                    child: _DocTypeOption(
                      icon: _docTypes[i].$1,
                      label: _docTypes[i].$2,
                      selected: _docType == i,
                      onTap: () => setState(() => _docType = i),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Dokumentasi ($_photoCount)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
            children: [
              for (var i = 0; i < _photoCount; i++)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        color: AppColors.textSecondary, size: 28),
                  ),
                ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: AppColors.textSecondary),
                      const SizedBox(height: 4),
                      Text('Tambah',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Catatan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Dokumentasi disimpan. File diunggah ke Google Drive '
                    'via backend (README bagian 17).',
                  ),
                ),
              );
            },
            child: const Text('Simpan Dokumentasi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

class _DocTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DocTypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
