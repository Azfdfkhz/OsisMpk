import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../budgets/pages/rab_page.dart';
import '../widgets/event_card.dart';

/// Halaman "Event" dengan tab Semua / Aktif / Selesai / Draft
/// sesuai desain mobile.
class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  static const _tabs = [
    ('Semua', 'ALL'),
    ('Aktif', StatusKeys.active),
    ('Selesai', StatusKeys.completed),
    ('Draft', StatusKeys.draft),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventStatusFilterProvider);
    final eventsAsync = ref.watch(eventListProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Event', style: AppTextStyles.h2),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tab in _tabs) ...[
                    ChoiceChip(
                      label: Text(tab.$1),
                      selected: filter == tab.$2,
                      selectedColor: AppColors.navy,
                      labelStyle: TextStyle(
                        color: filter == tab.$2 ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                      onSelected: (_) => ref.read(eventStatusFilterProvider.notifier).state = tab.$2,
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('Belum ada event pada kategori ini.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(
                      event: event,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RabPage(eventId: event.id, eventName: event.name)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat event: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
