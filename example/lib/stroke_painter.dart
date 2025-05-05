// stroke_painter.dart
import 'package:flutter/material.dart';

import 'package:freehand/models/stroke_options.dart';
import 'package:freehand/models/vec.dart';
import 'package:freehand/get_stroke.dart';
import 'completed_stroke.dart';

class StrokePainter extends CustomPainter {
  final List<Vec> points;
  final Color color;
  final StrokeOptions options;

  StrokePainter({
    required this.points,
    required this.color,
    required this.options,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final List<Vec> outlinePoints = getStroke(points, options: options);

    final Path path = Path();

    if (outlinePoints.isNotEmpty) {
      path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

      for (int i = 0; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];

        path.quadraticBezierTo(
          p0.x,
          p0.y,
          (p0.x + p1.x) / 2,
          (p0.y + p1.y) / 2,
        );
      }

      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.options != options;
  }
}

class MultiStrokePainter extends CustomPainter {
  final List<CompletedStroke> strokes;
  final List<Vec> currentStroke;
  final Color currentDrawingColor;
  final StrokeOptions currentDrawingOptions;

  MultiStrokePainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentDrawingColor,
    required this.currentDrawingOptions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final painter = StrokePainter(
        points: stroke.points,
        color: stroke.color,
        options: stroke.options,
      );
      painter.paint(canvas, size);
    }

    if (currentStroke.isNotEmpty) {
      final painter = StrokePainter(
        points: currentStroke,
        color: currentDrawingColor,
        options: currentDrawingOptions,
      );
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(MultiStrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.currentDrawingColor != currentDrawingColor ||
        oldDelegate.currentDrawingOptions != currentDrawingOptions;
  }
}
