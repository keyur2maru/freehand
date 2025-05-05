// lib/models/stroke_point.dart
import 'vec.dart';

class StrokePoint {
  Vec point;
  Vec input;
  Vec vector;
  double pressure;
  double distance;
  double runningLength;
  double radius;

  StrokePoint({
    required this.point,
    required this.input,
    required this.vector,
    required this.pressure,
    required this.distance,
    required this.runningLength,
    required this.radius,
  });
}