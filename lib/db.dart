import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class DB {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'daily.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            nama TEXT NOT NULL,
            ikon TEXT NOT NULL,
            warna TEXT,
            jadwalType INTEGER NOT NULL,
            hariJadwal TEXT NOT NULL,
            targetMingguan INTEGER,
            reminderJam TEXT,
            reminderAktif INTEGER NOT NULL,
            dibuatPada INTEGER NOT NULL,
            diarsipkan INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitId TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            status INTEGER NOT NULL,
            catatan TEXT,
            timestamp INTEGER NOT NULL,
            UNIQUE(habitId, tanggal)
          )
        ''');
        await db.execute('CREATE INDEX idx_logs_habit ON logs(habitId)');
        await db.execute('CREATE INDEX idx_logs_tanggal ON logs(tanggal)');
      },
    );
    return _db!;
  }

  static Future<List<Habit>> allHabits() async {
    final db = await instance;
    final rows = await db.query('habits', orderBy: 'dibuatPada ASC');
    return rows.map(Habit.fromMap).toList();
  }

  static Future<void> upsertHabit(Habit h) async {
    final db = await instance;
    await db.insert('habits', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteHabit(String id) async {
    final db = await instance;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('logs', where: 'habitId = ?', whereArgs: [id]);
  }

  static Future<List<LogEntry>> logsForHabit(String habitId) async {
    final db = await instance;
    final rows = await db
        .query('logs', where: 'habitId = ?', whereArgs: [habitId]);
    return rows.map(LogEntry.fromMap).toList();
  }

  static Future<List<LogEntry>> allLogs() async {
    final db = await instance;
    final rows = await db.query('logs');
    return rows.map(LogEntry.fromMap).toList();
  }

  static Future<void> upsertLog(LogEntry l) async {
    final db = await instance;
    await db.insert('logs', l.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteLog(String habitId, String tanggal) async {
    final db = await instance;
    await db.delete('logs',
        where: 'habitId = ? AND tanggal = ?', whereArgs: [habitId, tanggal]);
  }

  static Future<void> replaceAll(
      List<Habit> habits, List<LogEntry> logs) async {
    final db = await instance;
    await db.transaction((txn) async {
      await txn.delete('habits');
      await txn.delete('logs');
      for (final h in habits) {
        await txn.insert('habits', h.toMap());
      }
      for (final l in logs) {
        await txn.insert('logs', l.toMap());
      }
    });
  }
}
