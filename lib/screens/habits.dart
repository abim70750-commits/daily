import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import 'habit_edit.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final active = s.activeHabits;
    final archived = s.archivedHabits;

    return Scaffold(
      appBar: AppBar(title: Text(l.tabHabits)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          if (active.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(l.noHabitsToday,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ),
          ...active.map((h) => _Tile(habit: h)),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l.archive,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...archived.map((h) => _Tile(habit: h)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const HabitEditScreen(habit: null))),
        icon: const Icon(Icons.add),
        label: Text(l.addHabit),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Habit habit;
  const _Tile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Text(habit.ikon, style: const TextStyle(fontSize: 22)),
          title: Text(habit.nama),
          subtitle: Text(_scheduleStr(habit)),
          trailing: PopupMenuButton<String>(
            onSelected: (a) async {
              if (a == 'edit') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => HabitEditScreen(habit: habit)));
              } else if (a == 'archive') {
                await s.archiveHabit(habit, !habit.diarsipkan);
              } else if (a == 'delete') {
                await s.deleteHabit(habit.id);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l.editHabit)),
              PopupMenuItem(
                  value: 'archive',
                  child: Text(habit.diarsipkan ? 'Unarchive' : l.archive)),
              PopupMenuItem(value: 'delete', child: Text(l.delete)),
            ],
          ),
        ),
      ),
    );
  }

  String _scheduleStr(Habit h) {
    switch (h.jadwalType) {
      case JadwalType.daily:
        return 'Setiap hari';
      case JadwalType.weekly:
        const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        return h.hariJadwal.map((d) => names[d - 1]).join(', ');
      case JadwalType.flexible:
        return '${h.targetMingguan ?? 3}x per minggu';
    }
  }
}
