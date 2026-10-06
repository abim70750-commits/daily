import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final int done;
  final int total;
  final Color color;
  final double size;

  const ProgressRing({
    super.key,
    required this.done,
    required this.total,
    required this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              pct: pct,
              color: color,
              bg: color.withValues(alpha: 0.15),
            ),
          ),
          Text(
            '$done/$total',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final Color bg;
  _RingPainter({required this.pct, required this.color, required this.bg});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.10;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - stroke) / 2,
    );
    final paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = bg;
    canvas.drawArc(rect, 0, 2 * pi, false, paintBg);

    final paintFg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(rect, -pi / 2, 2 * pi * pct, false, paintFg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct || old.color != color;
}
