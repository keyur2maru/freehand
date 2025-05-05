// get_stroke_outline_points.dart
import 'dart:math';
import 'models/stroke_options.dart';
import 'models/stroke_point.dart';
import 'models/vec.dart';

const double pi = 3.141592653589793;

const double fixedPi = pi + 0.0001;

Map<String, List<Vec>> getStrokeOutlineTracks(
  List<StrokePoint> strokePoints, [
  StrokeOptions? options,
]) {
  options ??= StrokeOptions();
  final double size = options.size;
  final double smoothing = options.smoothing;

  if (strokePoints.isEmpty || size <= 0) {
    return {'left': [], 'right': []};
  }

  final StrokePoint firstStrokePoint = strokePoints[0];
  final StrokePoint lastStrokePoint = strokePoints[strokePoints.length - 1];

  final double totalLength = lastStrokePoint.runningLength;

  final double minDistance = pow(size * smoothing, 2).toDouble();

  final List<Vec> leftPts = [];
  final List<Vec> rightPts = [];

  Vec prevVector = strokePoints[0].vector;

  Vec pl = strokePoints[0].point;
  Vec pr = pl;

  Vec tl = pl;
  Vec tr = pr;

  bool isPrevPointSharpCorner = false;

  for (int i = 0; i < strokePoints.length; i++) {
    final StrokePoint strokePoint = strokePoints[i];
    final Vec point = strokePoint.point;
    final Vec vector = strokePoint.vector;

    final double prevDpr = vector.dpr(prevVector);
    final Vec nextVector =
        (i < strokePoints.length - 1)
            ? strokePoints[i + 1].vector
            : strokePoints[i].vector;

    final double nextDpr =
        i < strokePoints.length - 1 ? nextVector.dpr(vector) : 1;

    final bool isPointSharpCorner = prevDpr < 0 && !isPrevPointSharpCorner;
    final bool isNextPointSharpCorner = nextDpr < 0.2;

    if (isPointSharpCorner || isNextPointSharpCorner) {
      if (nextDpr > -0.62 &&
          totalLength - strokePoint.runningLength > strokePoint.radius) {
        // Draw a "soft" corner
        final Vec offset = prevVector.clone().mul(strokePoint.radius);
        final double cpr = prevVector.clone().cpr(nextVector);

        if (cpr < 0) {
          tl = Vec.addVec(point, offset);
          tr = Vec.subVec(point, offset);
        } else {
          tl = Vec.subVec(point, offset);
          tr = Vec.addVec(point, offset);
        }

        leftPts.add(tl);
        rightPts.add(tr);
      } else {
        // Draw a "sharp" corner
        final Vec offset = prevVector.clone().mul(strokePoint.radius).per();
        final Vec start = Vec.subVec(strokePoint.input, offset);

        for (double step = 1 / 13, t = 0; t < 1; t += step) {
          tl = Vec.rotWithVec(start, strokePoint.input, fixedPi * t);
          leftPts.add(tl);

          tr = Vec.rotWithVec(start, strokePoint.input, fixedPi + fixedPi * -t);
          rightPts.add(tr);
        }
      }

      pl = tl;
      pr = tr;

      if (isNextPointSharpCorner) {
        isPrevPointSharpCorner = true;
      }

      continue;
    }

    isPrevPointSharpCorner = false;

    if (strokePoint == firstStrokePoint || strokePoint == lastStrokePoint) {
      final Vec offset = vector.per().mul(strokePoint.radius);
      leftPts.add(Vec.subVec(point, offset));
      rightPts.add(Vec.addVec(point, offset));

      continue;
    }

    final Vec nextVectorLerped = Vec.lerpVec(nextVector, vector, nextDpr);
    final Vec offset = nextVectorLerped.per().mul(strokePoint.radius);

    tl = Vec.subVec(point, offset);

    if (i <= 1 || Vec.dist2Between(pl, tl) > minDistance) {
      leftPts.add(tl);
      pl = tl;
    }

    tr = Vec.addVec(point, offset);

    if (i <= 1 || Vec.dist2Between(pr, tr) > minDistance) {
      rightPts.add(tr);
      pr = tr;
    }

    prevVector = vector;
  }

  return {'left': leftPts, 'right': rightPts};
}

List<Vec> getStrokeOutlinePoints(
  List<StrokePoint> strokePoints, [
  StrokeOptions? options,
]) {
  options ??= StrokeOptions();
  final double size = options.size;
  final TaperOptions start = options.start;
  final TaperOptions end = options.end;
  final bool isComplete = options.last;

  final bool capStart = start.cap ?? true;
  final bool capEnd = end.cap ?? true;

  if (strokePoints.isEmpty || size <= 0) {
    return [];
  }

  final StrokePoint firstStrokePoint = strokePoints[0];
  final StrokePoint lastStrokePoint = strokePoints[strokePoints.length - 1];

  final double totalLength = lastStrokePoint.runningLength;

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

  final Map<String, List<Vec>> tracks = getStrokeOutlineTracks(
    strokePoints,
    options,
  );
  final List<Vec> leftPts = tracks['left']!;
  final List<Vec> rightPts = tracks['right']!;

  final Vec firstPoint = firstStrokePoint.point;

  final Vec lastPoint =
      strokePoints.length > 1
          ? strokePoints[strokePoints.length - 1].point
          : Vec.addXY(firstStrokePoint.point, 1, 1);

  if (strokePoints.length == 1) {
    if (!(taperStart > 0 || taperEnd > 0) || isComplete) {
      final Vec start = Vec.addVec(
        firstPoint,
        Vec.subVec(
          firstPoint,
          lastPoint,
        ).uni().per().mul(-firstStrokePoint.radius),
      );

      final List<Vec> dotPts = [];
      for (double step = 1 / 13, t = step; t <= 1; t += step) {
        dotPts.add(Vec.rotWithVec(start, firstPoint, fixedPi * 2 * t));
      }
      return dotPts;
    }
  }

  final List<Vec> startCap = [];
  if (taperStart > 0 || (taperEnd > 0 && strokePoints.length == 1)) {
  } else if (capStart) {
    for (double step = 1 / 8, t = step; t <= 1; t += step) {
      final Vec pt = Vec.rotWithVec(rightPts[0], firstPoint, fixedPi * t);
      startCap.add(pt);
    }
  } else {
    final Vec cornersVector = Vec.subVec(leftPts[0], rightPts[0]);
    final Vec offsetA = Vec.mulVec(cornersVector, 0.5);
    final Vec offsetB = Vec.mulVec(cornersVector, 0.51);

    startCap.addAll([
      Vec.subVec(firstPoint, offsetA),
      Vec.subVec(firstPoint, offsetB),
      Vec.addVec(firstPoint, offsetB),
      Vec.addVec(firstPoint, offsetA),
    ]);
  }

  final List<Vec> endCap = [];
  final Vec direction = lastStrokePoint.vector.clone().per().neg();

  if (taperEnd > 0 || (taperStart > 0 && strokePoints.length == 1)) {
    endCap.add(lastPoint);
  } else if (capEnd) {
    final Vec start = Vec.addVec(
      lastPoint,
      Vec.mulVec(direction, lastStrokePoint.radius),
    );
    for (double step = 1 / 29, t = step; t < 1; t += step) {
      endCap.add(Vec.rotWithVec(start, lastPoint, fixedPi * 3 * t));
    }
  } else {
    endCap.addAll([
      Vec.addVec(lastPoint, Vec.mulVec(direction, lastStrokePoint.radius)),
      Vec.addVec(
        lastPoint,
        Vec.mulVec(direction, lastStrokePoint.radius * 0.99),
      ),
      Vec.subVec(
        lastPoint,
        Vec.mulVec(direction, lastStrokePoint.radius * 0.99),
      ),
      Vec.subVec(lastPoint, Vec.mulVec(direction, lastStrokePoint.radius)),
    ]);
  }

  final List<Vec> result = [
    ...leftPts,
    ...endCap,
    ...rightPts.reversed,
    ...startCap,
  ];

  return result;
}
