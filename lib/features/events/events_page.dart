import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';
import '../rab/rab_page.dart';

/// Daftar Event — tab Semua / Aktif / Selesai / Draft (desain image.png).
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int _tab = 0; // 0 Semua, 1 Aktif, 2 Selesai, 3 Draft

  List<EventItem> get _filtered {
    switch (_tab) {
      case 1:
        return MockData.events.where((e) => e.status == EvStatus.active).toList();
      case 2:
        return MockData.events
            .where((e) => e.status == EvStatus.completed)
            .toList();
      default:
        return MockData.events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Semua', 'Aktif', 'Selesai', 'Draft'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    ChoiceChip(
                      label: Text(tabs[i]),
                      selected: _tab == i,
                      onSelected: (_) => setState(() => _tab = i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(event: _filtered[i]),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventItem event;
  const EventCard({super.key, required this.event});

  Color get _accent {
    switch (event.status) {
      case EvStatus.completed:
        return AppColors.green;
      case EvStatus.draft:
        return AppColors.amber;
      case EvStatus.active:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RABPage(event: event)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(event.icon, color: _accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(event.dateLabel,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text('Budget: ${formatRupiah(event.budget)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    event.progress == event.progress.roundToDouble()
                        ? '${event.progress.round()}%'
                        : '${event.progress}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: event.progress >= 100
                          ? AppColors.green
                          : AppColors.green,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 110,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: event.progress / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
