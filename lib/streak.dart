import 'models.dart';

/// Hitung streak untuk satu habit.
/// Return (current, longest).
(int, int) hitungStreak(Habit habit, List<LogEntry> logs) {
  final byDate = <String, LogStatus>{};
  for (final l in logs) {
    byDate[l.tanggal] = l.status;
  }

  final today = DateTime.now();
  final start = DateTime(habit.dibuatPada);

  int longest = 0;
  int run = 0;

  var d = DateTime(start.year, start.month, start.day);
  final end = DateTime(today.year, today.month, today.day);

  while (!d.isAfter(end)) {
    final key = ymd(d);
    if (habit.isScheduledOn(d)) {
      final st = byDate[key];
      if (st == LogStatus.done) {
        run++;
        if (run > longest) longest = run;
      } else if (st == LogStatus.skip) {
        // netral
      } else {
        run = 0;
      }
    }
    d = d.add(const Duration(days: 1));
  }

  int current = 0;
  var cur = DateTime(today.year, today.month, today.day);
  final startDay = DateTime(start.year, start.month, start.day);
  while (!cur.isBefore(startDay)) {
    final key = ymd(cur);
    if (habit.isScheduledOn(cur)) {
      final st = byDate[key];
      if (st == LogStatus.done) {
        current++;
      } else if (st == LogStatus.skip) {
        // netral
      } else {
        break;
      }
    }
    cur = cur.subtract(const Duration(days: 1));
  }

  return (current, longest);
}
