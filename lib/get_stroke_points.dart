// get_stroke_points.dart
import 'dart:math';
import 'models/stroke_options.dart';
import 'models/stroke_point.dart';
import 'models/vec.dart';

const double minStartPressure = 0.025;
const double minEndPressure = 0.01;

List<StrokePoint> getStrokePoints(
  List<dynamic> rawInputPoints, [
  StrokeOptions? options,
]) {
  options ??= StrokeOptions();
  final double streamline = options.streamline;
  final double size = options.size;
  final bool simulatePressure = options.simulatePressure;

  if (rawInputPoints.isEmpty) return [];

  final double t = 0.15 + (1 - streamline) * 0.85;

  List<Vec> pts = rawInputPoints.map((p) => Vec.from(p)).toList();

  int pointsRemovedFromNearEnd = 0;

  if (!simulatePressure) {
    Vec? pt = pts.isNotEmpty ? pts[0] : null;
    while (pt != null) {
      if (pt.z >= minStartPressure) break;
      pts.removeAt(0);
      pt = pts.isNotEmpty ? pts[0] : null;
    }
  }

  if (!simulatePressure) {
    Vec? pt = pts.isNotEmpty ? pts[pts.length - 1] : null;
    while (pt != null) {
      if (pt.z >= minEndPressure) break;
      pts.removeLast();
      pt = pts.isNotEmpty ? pts[pts.length - 1] : null;
    }
  }

  if (pts.isEmpty) {
    return [
      StrokePoint(
        point: Vec.from(rawInputPoints[0]),
        input: Vec.from(rawInputPoints[0]),
        pressure: simulatePressure ? 0.5 : 0.15,
        vector: Vec(1, 1),
        distance: 0,
        runningLength: 0,
        radius: 1,
      ),
    ];
  }

  Vec? pt = pts.length > 1 ? pts[1] : null;
  while (pt != null) {
    if (Vec.dist2Between(pt, pts[0]) > pow(size / 3, 2)) break;
    pts[0].z = max(pts[0].z, pt.z);
    pts.removeAt(1);
    pt = pts.length > 1 ? pts[1] : null;
  }

  final Vec last = pts.removeLast();
  pt = pts.isNotEmpty ? pts.last : null;
  while (pt != null) {
    if (Vec.dist2Between(pt, last) > pow(size / 3, 2)) break;
    pts.removeLast();
    pt = pts.isNotEmpty ? pts.last : null;
    pointsRemovedFromNearEnd++;
  }
  pts.add(last);

  final bool isComplete =
      options.last == true ||
      !simulatePressure ||
      (pts.length > 1 &&
          Vec.dist2Between(pts.last, pts[pts.length - 2]) < pow(size, 2)) ||
      pointsRemovedFromNearEnd > 0;

  // Add extra points between the two, to help avoid "dash" lines

  if (pts.length == 2 && simulatePressure) {
    final Vec last = pts[1];
    pts = pts.sublist(0, 1);
    for (int i = 1; i < 5; i++) {
      final Vec next = Vec.lerpVec(pts[0], last, i / 4);
      next.z = ((pts[0].z + (last.z - pts[0].z)) * i) / 4;
      pts.add(next);
    }
  }

  final List<StrokePoint> strokePoints = [
    StrokePoint(
      point: pts[0],
      input: pts[0],
      pressure: simulatePressure ? 0.5 : pts[0].z,
      vector: Vec(1, 1),
      distance: 0,
      runningLength: 0,
      radius: 1,
    ),
  ];

  double totalLength = 0;

  var prev = strokePoints[0];

  if (isComplete && streamline > 0) {
    pts.add(pts.last.clone());
  }

  for (int i = 1, n = pts.length; i < n; i++) {
    Vec point;
    if (t == 0 || (options.last == true && i == n - 1)) {
      point = pts[i].clone();
    } else {
      point = pts[i].clone().lrp(prev.point, 1 - t);
    }

    if (prev.point.equals(point)) continue;

    double distance = Vec.dist(point, prev.point);

    // Add this distance to the total "running length" of the line.
    totalLength += distance;

    if (i < 4 && totalLength < size) {
      continue;
    }

    // Create a new strokepoint (it will be the new "previous" one).
    prev = StrokePoint(
      input: pts[i],
      point: point,
      pressure: simulatePressure ? 0.5 : pts[i].z,
      vector: Vec.subVec(prev.point, point).uni(),
      distance: distance,
      runningLength: totalLength,
      radius: 1,
    );

    strokePoints.add(prev);
  }

  if (strokePoints.length > 1) {
    strokePoints[0].vector = strokePoints[1].vector.clone();
  }

  if (totalLength < 1) {
    final double maxPressureAmongPoints = [
      0.5,
      ...strokePoints.map((s) => s.pressure),
    ].reduce(max);
    for (var s in strokePoints) {
      s.pressure = maxPressureAmongPoints;
    }
  }

  return strokePoints;
}
