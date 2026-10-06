import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small outline icon, drawn locally to match the monochrome wireframe.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    this.conditionId = 802,
    this.isNight = false,
    this.size = 28,
  });

  final int conditionId;
  final bool isNight;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _WeatherPainter(conditionId, isNight)),
    ),
  );
}

class _WeatherPainter extends CustomPainter {
  const _WeatherPainter(this.code, this.night);
  final int code;
  final bool night;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32);
    final pen = Paint()
      ..color = const Color(0xFF44484E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final clear = code == 800;
    final rain = code >= 200 && code < 600;
    final snow = code >= 600 && code < 700;
    if (clear || code == 801 || code == 802) {
      final center = clear ? const Offset(16, 16) : const Offset(11, 11);
      if (night) {
        final moon = Path()
          ..moveTo(center.dx + 3, center.dy - 6)
          ..cubicTo(
            center.dx - 8,
            center.dy - 8,
            center.dx - 8,
            center.dy + 8,
            center.dx + 3,
            center.dy + 6,
          )
          ..quadraticBezierTo(
            center.dx - 4,
            center.dy + 2,
            center.dx + 3,
            center.dy - 6,
          );
        canvas.drawPath(moon, pen);
      } else {
        canvas.drawCircle(center, clear ? 6 : 4.5, pen);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final direction = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(
            center + direction * (clear ? 9 : 7),
            center + direction * (clear ? 12 : 9),
            pen,
          );
        }
      }
    }
    if (!clear) {
      final cloud = Path()
        ..moveTo(9, 24)
        ..cubicTo(2, 24, 2, 14, 9, 14)
        ..cubicTo(10, 6, 22, 6, 24, 15)
        ..cubicTo(31, 14, 32, 24, 25, 24)
        ..close();
      canvas.drawPath(cloud, Paint()..color = const Color(0xFFF4F4F5));
      canvas.drawPath(cloud, pen);
    }
    if (rain || snow) {
      for (final x in [11.0, 17.0, 23.0]) {
        canvas.drawLine(Offset(x, 27), Offset(x - 1.5, 30), pen);
        if (snow) canvas.drawLine(Offset(x - 2, 28), Offset(x + 1, 29), pen);
      }
    } else if (code >= 700 && code < 800) {
      canvas.drawLine(const Offset(9, 28), const Offset(24, 28), pen);
      canvas.drawLine(const Offset(12, 31), const Offset(21, 31), pen);
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter oldDelegate) =>
      oldDelegate.code != code || oldDelegate.night != night;
}
