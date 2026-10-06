import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../streak.dart';
import '../widgets/progress_ring.dart';
import 'habit_edit.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final scheduled = s.scheduledToday();
    final done = scheduled
        .where((h) => s.statusFor(h.id, ymd(now)) == LogStatus.done)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greet(l), style: const TextStyle(fontSize: 14)),
            Text(_dateStr(now),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProgressRing(
                done: done, total: scheduled.length, color: s.accent),
          ),
        ],
      ),
      body: scheduled.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.noHabitsToday,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
              itemCount: scheduled.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _HabitRow(habit: scheduled[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const HabitEditScreen(habit: null))),
        icon: const Icon(Icons.add),
        label: Text(l.addHabit),
      ),
    );
  }

  String _greet(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 11) return l.goodMorning;
    if (h < 15) return l.goodAfternoon;
    if (h < 19) return l.goodEvening;
    return l.goodNight;
  }

  String _dateStr(DateTime d) {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${names[d.weekday - 1]}, ${d.day} ${_month(d.month)}';
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ][m];
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  const _HabitRow({required this.habit});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final today = ymd(DateTime.now());
    final status = s.statusFor(habit.id, today);
    final done = status == LogStatus.done;
    final (cur, _) = hitungStreak(habit, s.logsOf(habit.id));
    final accent = s.accent;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final a = await showModalBottomSheet<String>(
            context: context,
            builder: (_) => SafeArea(
              child: Wrap(children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l.editHabit),
                  onTap: () => Navigator.pop(context, 'edit'),
                ),
                ListTile(
                  leading: const Icon(Icons.skip_next),
                  title: Text(l.skip),
                  onTap: () => Navigator.pop(context, 'skip'),
                ),
              ]),
            ),
          );
          if (a == 'edit') {
            if (!context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HabitEditScreen(habit: habit)));
          } else if (a == 'skip') {
            await s.setSkip(habit, DateTime.now());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(habit.ikon,
                    style: TextStyle(fontSize: 20, color: accent)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.nama,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          color:
                              done ? Theme.of(context).hintColor : null,
                        )),
                    if (cur > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('🔥 $cur ${l.days}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor)),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => s.toggleDone(habit, DateTime.now()),
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? accent : Theme.of(context).hintColor,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
