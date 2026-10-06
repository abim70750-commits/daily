import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

const _icons = [
  '🏃', '📚', '💧', '🧘', '🥗', '💤', '🚭', '💊',
  '✍️', '🎯', '🎸', '🏋️', '🧹', '💰', '☀️', '🌱',
  '🚶', '🎨', '🧠', '📝', '🛏️', '🥛', '🍎', '🎧',
];

class HabitEditScreen extends StatefulWidget {
  final Habit? habit;
  const HabitEditScreen({super.key, required this.habit});

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  late TextEditingController _name;
  late String _icon;
  late JadwalType _type;
  late List<int> _days;
  late int _target;
  late bool _reminderAktif;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.nama ?? '');
    _icon = h?.ikon ?? '🎯';
    _type = h?.jadwalType ?? JadwalType.daily;
    _days = List.from(h?.hariJadwal ?? const []);
    _target = h?.targetMingguan ?? 3;
    _reminderAktif = h?.reminderAktif ?? false;
    if (h?.reminderJam != null) {
      final p = h!.reminderJam!.split(':');
      _time = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? l.addHabit : l.editHabit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l.habitName),
            autofocus: widget.habit == null,
          ),
          const SizedBox(height: 16),
          Text(l.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _icons.map((e) {
              final sel = e == _icon;
              return GestureDetector(
                onTap: () => setState(() => _icon = e),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: sel
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(l.schedule, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          SegmentedButton<JadwalType>(
            segments: [
              ButtonSegment(value: JadwalType.daily, label: Text(l.daily)),
              ButtonSegment(value: JadwalType.weekly, label: Text(l.weekly)),
              ButtonSegment(value: JadwalType.flexible, label: Text(l.flexible)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          if (_type == JadwalType.weekly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final d = i + 1;
                final sel = _days.contains(d);
                const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                return FilterChip(
                  label: Text(names[i]),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _days.add(d);
                      } else {
                        _days.remove(d);
                      }
                    });
                  },
                );
              }),
            ),
          ],
          if (_type == JadwalType.flexible) ...[
            const SizedBox(height: 12),
            Row(children: [
              Text('${l.flexible}: '),
              Expanded(
                child: Slider(
                  value: _target.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_target',
                  onChanged: (v) => setState(() => _target = v.round()),
                ),
              ),
              Text('$_target x'),
            ]),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            value: _reminderAktif,
            onChanged: (v) => setState(() => _reminderAktif = v),
            title: Text(l.reminder),
            subtitle: Text(_time == null
                ? '—'
                : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'),
            secondary: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
                );
                if (t != null) {
                  setState(() {
                    _time = t;
                    _reminderAktif = true;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(l.save),
          ),
          const SizedBox(height: 8),
          if (widget.habit != null)
            TextButton.icon(
              onPressed: () async {
                await context.read<AppState>().deleteHabit(widget.habit!.id);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(l.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final h = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      nama: name,
      ikon: _icon,
      warna: widget.habit?.warna,
      jadwalType: _type,
      hariJadwal: _days,
      targetMingguan: _type == JadwalType.flexible ? _target : null,
      reminderJam: _reminderAktif && _time != null
          ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
          : null,
      reminderAktif: _reminderAktif,
      dibuatPada:
          widget.habit?.dibuatPada ?? DateTime.now().millisecondsSinceEpoch,
      diarsipkan: widget.habit?.diarsipkan ?? false,
    );
    await context.read<AppState>().saveHabit(h);
    if (mounted) Navigator.pop(context);
  }
}
