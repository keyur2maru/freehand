// get_stroke.dart
import 'models/stroke_options.dart';
import 'models/vec.dart';
import 'get_stroke_outline_points.dart';
import 'get_stroke_points.dart';
import 'set_stroke_point_radii.dart';

List<Vec> getStroke(List<dynamic> points, {StrokeOptions? options}) {
  options ??= StrokeOptions();

  final strokePoints = getStrokePoints(points, options);

  final pointsWithRadii = setStrokePointRadii(strokePoints, options);

  return getStrokeOutlinePoints(pointsWithRadii, options);
}
