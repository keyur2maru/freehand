# Freehand
[![pub package](https://img.shields.io/pub/v/freehand.svg)](https://pub.dev/packages/freehand)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue.svg)](https://github.com/keyur2maru/freehand)

A Flutter port of [Tldraw's perfect-freehand](https://github.com/tldraw/tldraw/tree/main/packages/perfect-freehand) drawing library. This package allows you to create smooth, pressure-sensitive freehand strokes from a series of input points.

It takes an array of 2D points (like those from touch or mouse events) and returns an outline shape representing a stroke with variable thickness.

## Motivation

While an official Dart port ([`perfect_freehand` on pub.dev](https://pub.dev/packages/perfect_freehand)) by the original author, Steve Ruiz, exists, it currently shares an issue with the original JavaScript library known as 'hot elbows' – the appearance of unintended sharp corners or artifacts, especially during fast drawing gestures ([see discussion #58](https://github.com/steveruizok/perfect-freehand/issues/58)).

Improvements to address this were developed and implemented within the version of the library used in the [Tldraw project](https://github.com/tldraw/tldraw). This `freehand` package aims to provide a Flutter port that incorporates these specific fixes (based on the Tldraw implementation), offering a smoother drawing experience without the 'hot elbow' artifacts.

## Features

* **Smooth Strokes:** Converts raw input points into a smooth, aesthetically pleasing stroke outline, incorporating fixes for common artifacts like "hot elbows".
* **Pressure Sensitivity:** Simulates pressure or uses actual pressure data (if available in input points) to vary stroke thickness.
* **Customizable Thinning:** Control how much pressure affects the stroke width.
* **Smoothing and Streamlining:** Adjust the level of smoothing and stabilization applied to the input points.
* **Tapering:** Apply customizable tapers to the start and end of strokes with various easing functions.
* **Cap Styles:** Control the appearance of stroke start and end caps (rounded or square).
* **Lightweight:** Pure Dart implementation with no platform-specific dependencies beyond Flutter.

## Getting Started

1.  **Add Dependency:** Add `freehand` to your `pubspec.yaml` file:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      freehand: ^0.0.1 # Use the latest version from pub.dev
    ```

2.  **Install:** Run `flutter pub get` in your terminal.

3.  **Import:** Import the package in your Dart code:

    ```dart
    import 'package:freehand/freehand.dart';
    ```

## Usage

The core function is `getStroke`. It takes a list of points and optional `StrokeOptions`.

1.  **Collect Input Points:** Gather points from user interactions, like `GestureDetector`'s `onPanUpdate`. The points can be `Vec` objects or simple `List<double>`/`Map<String, double>`.

    ```dart
    // Example using Vec from the package
    List<Vec> inputPoints = [
      Vec(10, 10, 0.5), // x, y, pressure (optional, defaults to 0)
      Vec(12, 15, 0.6),
      Vec(18, 14, 0.7),
      // ... more points
    ];

    // Or using other formats (will be converted internally)
    // List<List<double>> inputPoints = [ [10, 10], [12, 15], [18, 14] ];
    // List<Map<String, double>> inputPoints = [ {'x': 10, 'y': 10}, {'x': 12, 'y': 15} ];
    ```

2.  **Configure Stroke Options (Optional):** Customize the stroke's appearance. See `StrokeOptions` class for all parameters. Defaults are used if not provided (see Default Stroke Options table below).

    ```dart
    final options = StrokeOptions(
      size: 16,              // Base stroke size
      thinning: 0.7,         // Pressure sensitivity factor (0 to 1)
      smoothing: 0.5,        // Amount of point smoothing
      streamline: 0.5,       // Amount of path stabilization (lag)
      simulatePressure: true, // Generate pressure variance if input lacks it (z=0)
      start: TaperOptions(    // Tapering at the start
        taper: 10.0,         // Taper distance or true/false
        cap: true,           // Use a rounded cap
        easing: Easings.easeOutCubic, // Easing function for taper
      ),
      end: TaperOptions(      // Tapering at the end
        taper: 15.0,
        cap: true,
        easing: Easings.easeOutCubic,
      ),
      last: false,           // Set to true for the final stroke segment
    );
    ```

3.  **Generate Stroke Outline:** Call `getStroke` with your points and options.

    ```dart
    List<Vec> strokeOutline = getStroke(inputPoints, options: options);
    ```

4.  **Draw the Outline:** Use the returned `strokeOutline` points (which form a closed polygon) to draw a `Path` in a `CustomPainter`.

    ```dart
    class MyStrokePainter extends CustomPainter {
      final List<Vec> outlinePoints;
      final Color color;

      MyStrokePainter(this.outlinePoints, this.color);

      @override
      void paint(Canvas canvas, Size size) {
        if (outlinePoints.isEmpty) return;

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill; // Use fill for the outline polygon

        final path = Path();
        path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

        // Connect all points to form the outline
        for (int i = 1; i < outlinePoints.length; i++) {
          path.lineTo(outlinePoints[i].x, outlinePoints[i].y);
        }

        path.close(); // Close the path to complete the polygon
        canvas.drawPath(path, paint);

        // Note: For potentially smoother curves between outline points,
        // consider using quadraticBezierTo or cubicTo, like in the example app.
      }

      @override
      bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Or implement better logic
    }
    ```

## Example App

An example application demonstrating various features and options is included in the `/example` directory of the repository. You can run it to see the library in action and experiment with the different settings.

*(To run the example, clone the repository, navigate to the `example` directory, and run `flutter run`)*

## API Overview

* `getStroke(List<dynamic> points, {StrokeOptions? options})`: The main function to generate the stroke outline `List<Vec>`.
* `StrokeOptions`: Class to configure stroke appearance (size, thinning, smoothing, streamline, tapers, caps, easing, pressure simulation).
* `StrokePoint`: Internal representation of a point along the processed stroke path.
* `Vec`: A simple 2D vector class (with optional z for pressure).
* `Easings`: Provides common easing functions for tapers.

### Default Stroke Options

If `StrokeOptions` are not provided to `getStroke`, the following defaults are used:

| Option             | Default Value      | Description                                                      |
| ------------------ | ------------------ | ---------------------------------------------------------------- |
| `size`             | `16.0`             | Base stroke width.                                               |
| `thinning`         | `0.5`              | Pressure sensitivity factor (0: none, 1: full).                 |
| `smoothing`        | `0.5`              | Amount of point averaging (0: none).                             |
| `streamline`       | `0.5`              | Amount of path stabilization/lag (0: none).                      |
| `easing`           | `Easings.linear`   | Default easing function for pressure-related thinning.           |
| `simulatePressure` | `true`             | Generate pressure variations if input points lack pressure data. |
| `start.cap`        | `true`             | Use a rounded cap at the start.                                  |
| `start.taper`      | `false`            | Disable tapering at the start.                                   |
| `start.easing`     | `Easings.linear`   | Easing function for the start taper (if enabled).                |
| `end.cap`          | `true`             | Use a rounded cap at the end.                                    |
| `end.taper`        | `false`            | Disable tapering at the end.                                     |
| `end.easing`       | `Easings.linear`   | Easing function for the end taper (if enabled).                  |
| `last`             | `false`            | Indicates if this is the final segment of the stroke.            |

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues on the [GitHub repository](https://github.com/keyur2maru/freehand).

## Acknowledgements

This package is a Flutter port based on the excellent freehand drawing logic from the `perfect-freehand` JavaScript library, created by Steve Ruiz ([@steveruizok](https://github.com/steveruizok)).

The core algorithm and concepts are derived from his work, including the version integrated into the [Tldraw project](https://github.com/tldraw/tldraw). Many thanks to Steve for developing and sharing this elegant solution for freehand drawing.

## License

[MIT License](LICENSE) - Copyright (c) 2025 Keyur Maru