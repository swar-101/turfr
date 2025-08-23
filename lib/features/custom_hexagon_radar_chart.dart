import 'package:flutter/material.dart';
import 'dart:math';

class CustomHexagonRadarChart extends StatelessWidget {
  final List<String> features;
  final List<double> data;
  final Color accentColor;
  final Color gridColor;
  final Color textColor;
  final double maxValue;
  final List<double> ticks;

  const CustomHexagonRadarChart({
    Key? key,
    required this.features,
    required this.data,
    this.accentColor = Colors.purple,
    this.gridColor = Colors.white,
    this.textColor = Colors.white,
    this.maxValue = 100.0,
    this.ticks = const [20, 40, 60, 80, 100],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexagonRadarPainter(
        features: features,
        data: data,
        accentColor: accentColor,
        gridColor: gridColor,
        textColor: textColor,
        maxValue: maxValue,
        ticks: ticks,
      ),
      child: Container(),
    );
  }
}

class HexagonRadarPainter extends CustomPainter {
  final List<String> features;
  final List<double> data;
  final Color accentColor;
  final Color gridColor;
  final Color textColor;
  final double maxValue;
  final List<double> ticks;

  HexagonRadarPainter({
    required this.features,
    required this.data,
    required this.accentColor,
    required this.gridColor,
    required this.textColor,
    required this.maxValue,
    required this.ticks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 40;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw hexagonal grid lines for each tick
    for (int i = 0; i < ticks.length; i++) {
      final tickRadius = radius * (ticks[i] / maxValue);
      paint.color = gridColor.withValues(alpha: 0.3);
      _drawHexagon(canvas, center, tickRadius, paint);
    }

    // Draw axes from center to each vertex
    paint.color = gridColor.withValues(alpha: 0.5);
    for (int i = 0; i < features.length; i++) {
      final angle = (i * 2 * pi / features.length) - (pi / 2);
      final axisEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, axisEnd, paint);
    }

    // Draw data polygon
    if (data.isNotEmpty) {
      final dataPoints = <Offset>[];
      for (int i = 0; i < features.length; i++) {
        final angle = (i * 2 * pi / features.length) - (pi / 2);
        final value = i < data.length ? data[i] : 0.0;
        final normalizedValue = (value / maxValue).clamp(0.0, 1.0);
        final pointRadius = radius * normalizedValue;

        dataPoints.add(Offset(
          center.dx + pointRadius * cos(angle),
          center.dy + pointRadius * sin(angle),
        ));
      }

      // Fill the data polygon
      final fillPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final path = Path();
      if (dataPoints.isNotEmpty) {
        path.moveTo(dataPoints[0].dx, dataPoints[0].dy);
        for (int i = 1; i < dataPoints.length; i++) {
          path.lineTo(dataPoints[i].dx, dataPoints[i].dy);
        }
        path.close();
      }
      canvas.drawPath(path, fillPaint);

      // Draw data polygon outline
      final outlinePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, outlinePaint);

      // Draw data points
      final pointPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;

      for (final point in dataPoints) {
        canvas.drawCircle(point, 4.0, pointPaint);
      }
    }

    // Draw feature labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < features.length; i++) {
      final angle = (i * 2 * pi / features.length) - (pi / 2);
      final labelRadius = radius + 25;
      final labelCenter = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: features[i],
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();

      // Adjust text position based on angle to prevent overlap
      final textOffset = Offset(
        labelCenter.dx - textPainter.width / 2,
        labelCenter.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * pi / 6) - (pi / 2);
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
