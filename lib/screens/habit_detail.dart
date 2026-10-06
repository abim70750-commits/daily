import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../streak.dart';
import '../theme.dart';
import '../widgets/heatmap.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final logs = s.logsOf(habit.id);
    final (cur, longest) = hitungStreak(habit, logs);

    final counts = <String, int>{};
    final streakLevels = <String, int>{};
    for (final log in logs) {
      if (log.status == LogStatus.done) counts[log.tanggal] = 1;
    }
    final dates = counts.keys.toList()..sort();
    int run = 0;
    DateTime? prev;
    for (final d in dates) {
      final dt = DateTime.parse(d);
      if (prev != null && dt.difference(prev).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      streakLevels[d] = run;
      prev = dt;
    }

    return Scaffold(
      appBar: AppBar(title: Text(habit.nama)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Text(habit.ikon, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.currentStreak,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor)),
                      Text('$cur ${l.days}',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: streakColor(cur, s.accent))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l.longestStreak,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor)),
                    Text('$longest',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Heatmap(
                counts: counts,
                accent: s.accent,
                streakLevels: streakLevels,
                useStreakColor: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
