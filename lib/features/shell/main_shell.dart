import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/providers.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/pages/dashboard_page.dart';
import '../events/pages/event_list_page.dart';
import '../transactions/pages/transaction_list_page.dart';

/// Shell utama dengan bottom navigation: Beranda, Event, + (tambah cepat),
/// Transaksi, Akun — sesuai versi mobile pada desain.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _pages = [
    DashboardPage(),
    EventListPage(),
    TransactionListPage(), // placeholder untuk tombol tengah "+"
    TransactionListPage(),
    _AccountPlaceholderPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainNavIndexProvider);
    // Index 2 (tombol tengah "+") tidak menampilkan halaman, melainkan
    // membuka aksi tambah transaksi cepat.
    final pageIndex = index == 2 ? 3 : index;

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Beranda', selected: index == 0, onTap: () => _select(ref, 0)),
              _NavItem(icon: Icons.event_note_rounded, label: 'Event', selected: index == 1, onTap: () => _select(ref, 1)),
              _CenterAddButton(onTap: () => _showQuickAdd(context)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Transaksi', selected: index == 3, onTap: () => _select(ref, 3)),
              _NavItem(icon: Icons.person_rounded, label: 'Akun', selected: index == 4, onTap: () => _select(ref, 4)),
            ],
          ),
        ),
      ),
    );
  }

  void _select(WidgetRef ref, int index) {
    ref.read(mainNavIndexProvider.notifier).state = index;
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: AppColors.success),
              title: const Text('Tambah Pemasukan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: AppColors.danger),
              title: const Text('Tambah Pengeluaran'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined, color: AppColors.blue),
              title: const Text('Tambah Event'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Placeholder sederhana untuk tab "Akun" (README bagian 27: features/settings).
class _AccountPlaceholderPage extends ConsumerWidget {
  const _AccountPlaceholderPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Akun')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.navy, child: Icon(Icons.person, color: Colors.white)),
              title: Text(user.fullName),
              subtitle: Text(user.roleName),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Persetujuan'),
                  // README bagian 15.5 (v_pending_approvals_count): jumlah
                  // pengajuan RAB/transaksi yang masih menunggu persetujuan.
                  trailing: const _ApprovalBadge(count: 3),
                ),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.description_outlined), title: Text('Laporan')),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.folder_outlined), title: Text('Dokumentasi')),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Pengaturan')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'OSIS Finance v${AppConstants.appVersion}'
              '${AppConstants.isTestingBuild ? ' (Testing)' : ''}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalBadge extends StatelessWidget {
  final int count;
  const _ApprovalBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
