enum JadwalType { daily, weekly, flexible }
enum LogStatus { done, skip, kosong }

class Habit {
  final String id;
  String nama;
  String ikon;
  String? warna;
  JadwalType jadwalType;
  List<int> hariJadwal;
  int? targetMingguan;
  String? reminderJam;
  bool reminderAktif;
  int dibuatPada;
  bool diarsipkan;

  Habit({
    required this.id,
    required this.nama,
    this.ikon = '🎯',
    this.warna,
    this.jadwalType = JadwalType.daily,
    this.hariJadwal = const [],
    this.targetMingguan,
    this.reminderJam,
    this.reminderAktif = false,
    required this.dibuatPada,
    this.diarsipkan = false,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nama': nama,
        'ikon': ikon,
        'warna': warna,
        'jadwalType': jadwalType.index,
        'hariJadwal': hariJadwal.join(','),
        'targetMingguan': targetMingguan,
        'reminderJam': reminderJam,
        'reminderAktif': reminderAktif ? 1 : 0,
        'dibuatPada': dibuatPada,
        'diarsipkan': diarsipkan ? 1 : 0,
      };

  factory Habit.fromMap(Map<String, Object?> m) => Habit(
        id: m['id'] as String,
        nama: m['nama'] as String,
        ikon: m['ikon'] as String,
        warna: m['warna'] as String?,
        jadwalType: JadwalType.values[m['jadwalType'] as int],
        hariJadwal: (m['hariJadwal'] as String).isEmpty
            ? []
            : (m['hariJadwal'] as String).split(',').map(int.parse).toList(),
        targetMingguan: m['targetMingguan'] as int?,
        reminderJam: m['reminderJam'] as String?,
        reminderAktif: (m['reminderAktif'] as int) == 1,
        dibuatPada: m['dibuatPada'] as int,
        diarsipkan: (m['diarsipkan'] as int) == 1,
      );

  bool isScheduledOn(DateTime d) {
    switch (jadwalType) {
      case JadwalType.daily:
        return true;
      case JadwalType.weekly:
        return hariJadwal.contains(d.weekday);
      case JadwalType.flexible:
        return true;
    }
  }
}

class LogEntry {
  final int? id;
  final String habitId;
  final String tanggal;
  final LogStatus status;
  final String? catatan;
  final int timestamp;

  LogEntry({
    this.id,
    required this.habitId,
    required this.tanggal,
    required this.status,
    this.catatan,
    required this.timestamp,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'habitId': habitId,
        'tanggal': tanggal,
        'status': status.index,
        'catatan': catatan,
        'timestamp': timestamp,
      };

  factory LogEntry.fromMap(Map<String, Object?> m) => LogEntry(
        id: m['id'] as int?,
        habitId: m['habitId'] as String,
        tanggal: m['tanggal'] as String,
        status: LogStatus.values[m['status'] as int],
        catatan: m['catatan'] as String?,
        timestamp: m['timestamp'] as int,
      );
}

String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
