import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class Heatmap extends StatelessWidget {
  final Map<String, int> counts;
  final Map<String, int>? streakLevels;
  final Color accent;
  final int days;
  final bool useStreakColor;

  const Heatmap({
    super.key,
    required this.counts,
    required this.accent,
    this.streakLevels,
    this.days = 365,
    this.useStreakColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: days - 1));
    final weeks = ((days + start.weekday - 1) / 7).ceil();

    return LayoutBuilder(builder: (context, c) {
      final cell = (c.maxWidth - (weeks - 1) * 3) / weeks;
      final sz = cell.clamp(3.0, 12.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: sz * 7 + 6 * 3 + 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: List.generate(weeks, (w) {
                  return Padding(
                    padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 3),
                    child: Column(
                      children: List.generate(7, (d) {
                        final day = start.add(Duration(days: w * 7 + d));
                        if (day.isAfter(today)) {
                          return SizedBox(width: sz, height: sz + 3);
                        }
                        final key = ymd(day);
                        final n = counts[key] ?? 0;
                        Color col;
                        if (useStreakColor &&
                            streakLevels != null &&
                            (streakLevels![key] ?? 0) > 0) {
                          col = streakColor(streakLevels![key]!, accent);
                        } else {
                          col = heatmapNormal(accent, n.clamp(0, 3));
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Container(
                            width: sz,
                            height: sz,
                            decoration: BoxDecoration(
                              color: col,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Kurang',
                  style: TextStyle(
                      fontSize: 10, color: Theme.of(context).hintColor)),
              const SizedBox(width: 6),
              ...[0, 1, 2, 3].map((l) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: heatmapNormal(accent, l),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
              const SizedBox(width: 6),
              Text('Lebih',
                  style: TextStyle(
                      fontSize: 10, color: Theme.of(context).hintColor)),
            ],
          ),
        ],
      );
    });
  }
}
