import 'package:flutter/material.dart';
import 'package:freehand/models/stroke_options.dart';
import 'package:freehand/models/vec.dart';

class CompletedStroke {
  final List<Vec> points;
  final Color color;
  final StrokeOptions options;

  CompletedStroke({
    required this.points,
    required this.color,
    required this.options,
  });
}
