import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/mock_data.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/events/events_page.dart';
import '../features/logistics/logistics_page.dart';
import '../features/rab/rab_page.dart';
import '../features/transactions/transactions_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _showAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    if (isDesktop) {
      const placeholders = ['Laporan', 'Dokumentasi', 'Persetujuan', 'Pengaturan'];
      final pages = [
        const DashboardPage(),
        const EventsPage(),
        const TransactionsPage(),
        RABPage(event: MockData.porseni),
        LogisticsPage(event: MockData.porseni),
        for (final p in placeholders) _PlaceholderPage(p),
      ];
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _Sidebar(
              index: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
      );
    }

    const mobilePages = [
      MobileHomePage(),
      EventsPage(),
      TransactionsPage(),
      _ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: mobilePages),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaction,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Event',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 48), // ruang FAB
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Transaksi',
              selected: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Akun',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
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

  const _NavItem({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _Sidebar({required this.index, required this.onSelect});

  static const _items = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.calendar_today_outlined, 'Event'),
    (Icons.receipt_long_outlined, 'Transaksi'),
    (Icons.description_outlined, 'RAB'),
    (Icons.inventory_2_outlined, 'Logistik'),
    (Icons.assessment_outlined, 'Laporan'),
    (Icons.folder_outlined, 'Dokumentasi'),
    (Icons.task_alt_outlined, 'Persetujuan'),
    (Icons.settings_outlined, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    const user = MockData.currentUser;
    return Container(
      width: 236,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 26),
                SizedBox(width: 10),
                Text(
                  'OSIS\nMPK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final selected = i == index;
                final badge = i == 7 ? MockData.pendingApprovals : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: selected
                        ? Colors.white.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onSelect(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              _items[i].$1,
                              size: 20,
                              color: Colors.white.withOpacity(
                                  selected ? 1.0 : 0.75),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _items[i].$2,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                      selected ? 1.0 : 0.75),
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (badge > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.purple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$badge',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text(user.role,
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    const user = MockData.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.navy,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(user.name,
                style: Theme.of(context).textTheme.titleMedium),
            Text(user.role, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('$title — segera hadir',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Mengikuti roadmap README Phase 7-8',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AddTransactionSheet extends StatelessWidget {
  const _AddTransactionSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tambah Transaksi',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Judul', hintText: 'Pembelian konsumsi'),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Nominal (Rp)', hintText: '250000'),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(labelText: 'Event', hintText: 'PORSENI 2024'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan (demo)'),
          ),
        ],
      ),
    );
  }
}
