import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db.dart';
import 'models.dart';
import 'notifications.dart';

class AppState extends ChangeNotifier {
  List<Habit> habits = [];
  List<LogEntry> logs = [];
  Color accent = const Color(0xFF7C4DFF);
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accent = Color(prefs.getInt('accent') ?? 0xFF7C4DFF);
    themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    final lang = prefs.getString('locale');
    locale = lang == null ? null : Locale(lang);

    habits = await DB.allHabits();
    logs = await DB.allLogs();
    notifyListeners();
  }

  Future<void> setAccent(Color c) async {
    accent = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent', c.value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', m.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale? l) async {
    locale = l;
    final prefs = await SharedPreferences.getInstance();
    if (l == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', l.languageCode);
    }
    notifyListeners();
  }

  List<Habit> get activeHabits => habits.where((h) => !h.diarsipkan).toList();
  List<Habit> get archivedHabits => habits.where((h) => h.diarsipkan).toList();

  List<Habit> scheduledToday() {
    final now = DateTime.now();
    return activeHabits.where((h) => h.isScheduledOn(now)).toList();
  }

  LogStatus statusFor(String habitId, String tanggal) {
    for (final l in logs) {
      if (l.habitId == habitId && l.tanggal == tanggal) return l.status;
    }
    return LogStatus.kosong;
  }

  List<LogEntry> logsOf(String habitId) =>
      logs.where((l) => l.habitId == habitId).toList();

  Future<void> toggleDone(Habit h, DateTime d) async {
    final key = ymd(d);
    final current = statusFor(h.id, key);
    if (current == LogStatus.done) {
      await DB.deleteLog(h.id, key);
      logs.removeWhere((l) => l.habitId == h.id && l.tanggal == key);
    } else {
      final entry = LogEntry(
        habitId: h.id,
        tanggal: key,
        status: LogStatus.done,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await DB.upsertLog(entry);
      logs.removeWhere((l) => l.habitId == h.id && l.tanggal == key);
      logs.add(entry);
    }
    notifyListeners();
  }

  Future<void> setSkip(Habit h, DateTime d) async {
    final key = ymd(d);
    final entry = LogEntry(
      habitId: h.id,
      tanggal: key,
      status: LogStatus.skip,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await DB.upsertLog(entry);
    logs.removeWhere((l) => l.habitId == h.id && l.tanggal == key);
    logs.add(entry);
    notifyListeners();
  }

  Future<void> saveHabit(Habit h) async {
    await DB.upsertHabit(h);
    habits.removeWhere((x) => x.id == h.id);
    habits.add(h);
    habits.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
    if (h.reminderAktif && h.reminderJam != null) {
      final parts = h.reminderJam!.split(':');
      await NotificationsService.scheduleDaily(
        id: h.id.hashCode,
        title: 'Daily',
        body: h.nama,
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      await NotificationsService.cancel(h.id.hashCode);
    }
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await DB.deleteHabit(id);
    habits.removeWhere((h) => h.id == id);
    logs.removeWhere((l) => l.habitId == id);
    await NotificationsService.cancel(id.hashCode);
    notifyListeners();
  }

  Future<void> archiveHabit(Habit h, bool archived) async {
    h.diarsipkan = archived;
    await DB.upsertHabit(h);
    notifyListeners();
  }

  Future<File> exportJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/daily-backup.json');
    final data = {
      'version': 1,
      'habits': habits.map((h) => h.toMap()).toList(),
      'logs': logs.map((l) => l.toMap()).toList(),
      'accent': accent.value,
      'themeMode': themeMode.index,
      'locale': locale?.languageCode,
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> importJson(String jsonStr, {bool replace = true}) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final h = (data['habits'] as List)
        .map((m) => Habit.fromMap(Map<String, Object?>.from(m)))
        .toList();
    final l = (data['logs'] as List)
        .map((m) => LogEntry.fromMap(Map<String, Object?>.from(m)))
        .toList();
    if (replace) {
      await DB.replaceAll(h, l);
      habits = h;
      logs = l;
    } else {
      for (final x in h) {
        await DB.upsertHabit(x);
      }
      for (final x in l) {
        await DB.upsertLog(x);
      }
      habits = await DB.allHabits();
      logs = await DB.allLogs();
    }
    notifyListeners();
  }
}
