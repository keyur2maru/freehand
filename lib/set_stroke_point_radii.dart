// set_stroke_point_radii.dart
import 'dart:math';
import 'models/stroke_options.dart';
import 'models/stroke_point.dart';
import 'utils/easings.dart';

const double rateOfPressureChange = 0.275;

List<StrokePoint> setStrokePointRadii(
  List<StrokePoint> strokePoints, [
  StrokeOptions? options,
]) {
  options ??= StrokeOptions();
  final double size = options.size;
  final double thinning = options.thinning;
  final bool simulatePressure = options.simulatePressure;
  final NumericEasing easing = options.easing;
  final TaperOptions start = options.start;
  final TaperOptions end = options.end;

  final NumericEasing taperStartEase = start.easing ?? Easings.easeOutQuad;
  final NumericEasing taperEndEase = end.easing ?? Easings.easeOutCubic;

  final double totalLength = strokePoints.last.runningLength;
  double? firstRadius;
  double prevPressure = strokePoints[0].pressure;
  StrokePoint strokePoint;

  if (!simulatePressure && totalLength < size) {
    final double max = strokePoints.fold(
      0.5,
      (maxVal, curr) => curr.pressure > maxVal ? curr.pressure : maxVal,
    );
    for (var sp in strokePoints) {
      sp.pressure = max;
      sp.radius = size * easing(0.5 - thinning * (0.5 - sp.pressure));
    }
    return strokePoints;
  } else {
    double p = 0;
    for (int i = 0, n = strokePoints.length; i < n; i++) {
      strokePoint = strokePoints[i];
      if (strokePoint.runningLength > size * 5) break;

      final double sp = min(1.0, strokePoint.distance / size);
      if (simulatePressure) {
        final double rp = min(1.0, 1 - sp);
        p = min(
          1.0,
          prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
        );
      } else {
        p = min(
          1.0,
          prevPressure + (strokePoint.pressure - prevPressure) * 0.5,
        );
      }
      prevPressure = prevPressure + (p - prevPressure) * 0.5;
    }

    for (int i = 0; i < strokePoints.length; i++) {
      strokePoint = strokePoints[i];
      if (thinning > 0) {
        double pressure = strokePoint.pressure;
        final double sp = min(1.0, strokePoint.distance / size);

        if (simulatePressure) {
          final double rp = min(1.0, 1 - sp);
          pressure = min(
            1.0,
            prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange),
          );
        } else {
          pressure = min(
            1.0,
            prevPressure +
                (pressure - prevPressure) * (sp * rateOfPressureChange),
          );
        }

        strokePoint.radius = size * easing(0.5 - thinning * (0.5 - pressure));
        prevPressure = pressure;
      } else {
        strokePoint.radius = size / 2;
      }

      firstRadius ??= strokePoint.radius;
    }
  }

  final double taperStart =
      start.taper == null || start.taper == false
          ? 0
          : start.taper == true
          ? max(size, totalLength)
          : (start.taper as double);

  final double taperEnd =
      end.taper == null || end.taper == false
          ? 0
          : end.taper == true
          ? max(size, totalLength)
          : (end.taper as double);

  if (taperStart > 0 || taperEnd > 0) {
    for (int i = 0; i < strokePoints.length; i++) {
      strokePoint = strokePoints[i];

      final double runningLength = strokePoint.runningLength;
      final double ts =
          runningLength < taperStart
              ? taperStartEase(runningLength / taperStart)
              : 1;

      final double te =
          totalLength - runningLength < taperEnd
              ? taperEndEase((totalLength - runningLength) / taperEnd)
              : 1;

      strokePoint.radius = max(0.01, strokePoint.radius * min(ts, te));
    }
  }

  return strokePoints;
}
