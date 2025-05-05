// easings.dart
import 'dart:math';

class Easings {
  static double linear(double t) => t;

  static double easeInQuad(double t) => t * t;

  static double easeOutQuad(double t) => 1 - (1 - t) * (1 - t);

  static double easeInOutQuad(double t) {
    return t < 0.5
        ? 2 * t * t
        : 1 - pow(-2 * t + 2, 2) / 2;
  }

  static double easeInCubic(double t) => t * t * t;

  static double easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();

  static double easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - pow(-2 * t + 2, 3) / 2;
  }
}