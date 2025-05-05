// lib/models/stroke_options.dart
import 'package:freehand/utils/easings.dart';

typedef NumericEasing = double Function(double value);

class TaperOptions {
  final bool? cap;
  final dynamic taper;
  final NumericEasing? easing;

  const TaperOptions({this.cap, this.taper, this.easing});
}

class StrokeOptions {
  static double defaultSize = 16;
  static double defaultThinning = 0.5;
  static double defaultSmoothing = 0.5;
  static double defaultStreamline = 0.5;
  static NumericEasing defaultEasing = Easings.linear;
  static bool defaultSimulatePressure = true;
  static bool defaultLast = false;
  static TaperOptions defaultStart = const TaperOptions(
    cap: true,
    taper: false,
    easing: Easings.linear,
  );
  static TaperOptions defaultEnd = const TaperOptions(
    cap: true,
    taper: false,
    easing: Easings.linear,
  );

  double size;
  double thinning;
  double smoothing;
  double streamline;
  NumericEasing easing;
  bool simulatePressure;
  TaperOptions start;
  TaperOptions end;
  bool last;

  StrokeOptions({
    double? size,
    double? thinning,
    double? smoothing,
    double? streamline,
    NumericEasing? easing,
    bool? simulatePressure,
    TaperOptions? start,
    TaperOptions? end,
    bool? last,
  }) : size = size ?? defaultSize,
       thinning = thinning ?? defaultThinning,
       smoothing = smoothing ?? defaultSmoothing,
       streamline = streamline ?? defaultStreamline,
       easing = easing ?? defaultEasing,
       simulatePressure = simulatePressure ?? defaultSimulatePressure,
       start = start ?? defaultStart,
       end = end ?? defaultEnd,
       last = last ?? defaultLast;

  StrokeOptions copyWith({
    double? size,
    double? thinning,
    double? smoothing,
    double? streamline,
    NumericEasing? easing,
    bool? simulatePressure,
    TaperOptions? start,
    TaperOptions? end,
    bool? last,
  }) {
    return StrokeOptions(
      size: size ?? this.size,
      thinning: thinning ?? this.thinning,
      smoothing: smoothing ?? this.smoothing,
      streamline: streamline ?? this.streamline,
      easing: easing ?? this.easing,
      simulatePressure: simulatePressure ?? this.simulatePressure,
      start: start ?? this.start,
      end: end ?? this.end,
      last: last ?? this.last,
    );
  }
}
