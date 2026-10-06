import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../streak.dart';
import '../widgets/heatmap.dart';
import 'habit_detail.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);

    final counts = <String, int>{};
    for (final log in s.logs) {
      if (log.status == LogStatus.done) {
        counts[log.tanggal] = (counts[log.tanggal] ?? 0) + 1;
      }
    }

    int longestActive = 0;
    for (final h in s.activeHabits) {
      final (c, _) = hitungStreak(h, s.logsOf(h.id));
      if (c > longestActive) longestActive = c;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.tabStats)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('365 hari',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: 10),
                  Heatmap(counts: counts, accent: s.accent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _Big(
                label: l.currentStreak,
                value: '$longestActive',
                color: s.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Big(
                label: l.totalCheckins,
                value:
                    '${s.logs.where((e) => e.status == LogStatus.done).length}',
                color: s.accent,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _Big(
            label: l.activeHabits,
            value: '${s.activeHabits.length}',
            color: s.accent,
          ),
          const SizedBox(height: 16),
          Text('Per habit',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...s.activeHabits.map((h) {
            final (c, l2) = hitungStreak(h, s.logsOf(h.id));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => HabitDetailScreen(habit: h))),
                  leading: Text(h.ikon, style: const TextStyle(fontSize: 22)),
                  title: Text(h.nama),
                  subtitle: Text('🔥 $c · ${l.longestStreak}: $l2'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Big extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Big({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
