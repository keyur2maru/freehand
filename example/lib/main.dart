import 'package:flutter/material.dart';
import 'package:freehand/models/stroke_options.dart';
import 'package:freehand/utils/easings.dart';
import 'package:freehand/models/vec.dart';
import 'stroke_painter.dart';
import 'completed_stroke.dart';

typedef EasingSelection = ({String name, NumericEasing function});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freehand Drawing Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const DrawingCanvas(),
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<CompletedStroke> strokes = [];

  List<Vec> currentStroke = [];

  Color _currentColor = Colors.black;
  double _strokeSize = 16.0;
  double _strokeThinning = 0.5;
  double _strokeSmoothing = 0.5;
  double _strokeStreamline = 0.5;
  bool _simulatePressure = true;

  bool _startCap = StrokeOptions.defaultStart.cap ?? true;
  bool _startTaperEnabled =
      StrokeOptions.defaultStart.taper is double ||
      (StrokeOptions.defaultStart.taper is bool &&
          StrokeOptions.defaultStart.taper == true);
  double _startTaperValue =
      StrokeOptions.defaultStart.taper is double
          ? StrokeOptions.defaultStart.taper as double
          : 0.0;
  EasingSelection _startEasing = (name: 'Linear', function: Easings.linear);

  bool _endCap = StrokeOptions.defaultEnd.cap ?? true;
  bool _endTaperEnabled =
      StrokeOptions.defaultEnd.taper is double ||
      (StrokeOptions.defaultEnd.taper is bool &&
          StrokeOptions.defaultEnd.taper == true);
  double _endTaperValue =
      StrokeOptions.defaultEnd.taper is double
          ? StrokeOptions.defaultEnd.taper as double
          : 0.0;
  EasingSelection _endEasing = (name: 'Linear', function: Easings.linear);

  final List<EasingSelection> _availableEasings = [
    (name: 'Linear', function: Easings.linear),
    (name: 'InQuad', function: Easings.easeInQuad),
    (name: 'OutQuad', function: Easings.easeOutQuad),
    (name: 'InOutQuad', function: Easings.easeInOutQuad),
    (name: 'InCubic', function: Easings.easeInCubic),
    (name: 'OutCubic', function: Easings.easeOutCubic),
    (name: 'InOutCubic', function: Easings.easeInOutCubic),
  ];

  bool _isMenuExpanded = true;

  final List<Color> _colorOptions = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  currentStroke = [
                    Vec(details.localPosition.dx, details.localPosition.dy),
                  ];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  currentStroke.add(
                    Vec(details.localPosition.dx, details.localPosition.dy),
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  if (currentStroke.isNotEmpty) {
                    final strokeOptions = StrokeOptions(
                      size: _strokeSize,
                      thinning: _strokeThinning,
                      smoothing: _strokeSmoothing,
                      streamline: _strokeStreamline,
                      simulatePressure: _simulatePressure,

                      start: TaperOptions(
                        cap: _startCap,
                        taper: _startTaperEnabled ? _startTaperValue : false,
                        easing: _startEasing.function,
                      ),
                      end: TaperOptions(
                        cap: _endCap,
                        taper: _endTaperEnabled ? _endTaperValue : false,
                        easing: _endEasing.function,
                      ),
                    );

                    final completed = CompletedStroke(
                      points: List.from(currentStroke),
                      color: _currentColor,
                      options: strokeOptions,
                    );
                    strokes.add(completed);
                  }
                  currentStroke = [];
                });
              },
              child: CustomPaint(
                painter: MultiStrokePainter(
                  strokes: strokes,
                  currentStroke: currentStroke,

                  currentDrawingColor: _currentColor,
                  currentDrawingOptions: StrokeOptions(
                    size: _strokeSize,
                    thinning: _strokeThinning,
                    smoothing: _strokeSmoothing,
                    streamline: _strokeStreamline,
                    simulatePressure: _simulatePressure,

                    start: TaperOptions(
                      cap: _startCap,
                      taper: _startTaperEnabled ? _startTaperValue : false,
                      easing: _startEasing.function,
                    ),
                    end: TaperOptions(
                      cap: _endCap,
                      taper: _endTaperEnabled ? _endTaperValue : false,
                      easing: _endEasing.function,
                    ),
                  ),
                ),
                child: Container(),
              ),
            ),
          ),

          _buildFloatingMenu(),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu() {
    final animationDuration = const Duration(milliseconds: 200);
    return Positioned(
      top: 20.0,
      right: 10.0,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedSize(
          duration: animationDuration,
          curve: Curves.easeInOut,

          alignment: Alignment.topCenter,
          child: Container(
            width: _isMenuExpanded ? 200.0 : 60.0,

            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isMenuExpanded
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_rounded,
                      size: 18,
                    ),
                    tooltip: _isMenuExpanded ? 'Collapse Menu' : 'Expand Menu',
                    onPressed: () {
                      setState(() {
                        _isMenuExpanded = !_isMenuExpanded;
                      });
                    },
                  ),
                ),

                AnimatedCrossFade(
                  duration: animationDuration,
                  crossFadeState:
                      _isMenuExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: _buildControlPanelContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanelContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children:
                _colorOptions.map((color) => _buildColorButton(color)).toList(),
          ),
          const Divider(height: 20),

          _buildSliderRow(
            'Size',
            _strokeSize,
            1.0,
            50.0,
            (val) => _strokeSize = val,
          ),
          _buildSliderRow(
            'Thinning',
            _strokeThinning,
            0.0,
            1.0,
            (val) => _strokeThinning = val,
          ),
          _buildSliderRow(
            'Smoothing',
            _strokeSmoothing,
            0.0,
            1.0,
            (val) => _strokeSmoothing = val,
          ),
          _buildSliderRow(
            'Streamline',
            _strokeStreamline,
            0.0,
            1.0,
            (val) => _strokeStreamline = val,
          ),

          const Divider(height: 20, indent: 16, endIndent: 16),

          const Text(
            'Start Taper:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildSwitchRow('Cap', _startCap, (val) => _startCap = val),
          _buildSwitchRow(
            'Enable Taper',
            _startTaperEnabled,
            (val) => _startTaperEnabled = val,
          ),

          if (_startTaperEnabled)
            _buildSliderRow(
              'Taper Value',
              _startTaperValue,
              0.0,
              10.0,
              (val) => _startTaperValue = val,
              divisions: 100,
            ),
          _buildDropdownRow<EasingSelection>(
            'Easing',
            _startEasing,
            _availableEasings,
            (selection) => selection.name,
            (val) => _startEasing = val!,
          ),

          const Divider(height: 20, indent: 16, endIndent: 16),

          const Text(
            'End Taper:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildSwitchRow('Cap', _endCap, (val) => _endCap = val),
          _buildSwitchRow(
            'Enable Taper',
            _endTaperEnabled,
            (val) => _endTaperEnabled = val,
          ),

          if (_endTaperEnabled)
            _buildSliderRow(
              'Taper Value',
              _endTaperValue,
              0.0,
              10.0,
              (val) => _endTaperValue = val,
              divisions: 100,
            ),
          _buildDropdownRow<EasingSelection>(
            'Easing',
            _endEasing,
            _availableEasings,
            (selection) => selection.name,
            (val) => _endEasing = val!,
          ),

          const Divider(height: 20),

          _buildSwitchRow(
            'Pressure',
            _simulatePressure,
            (val) => _simulatePressure = val,
          ),
          const Divider(height: 20),

          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear Canvas'),
              onPressed: () {
                setState(() {
                  strokes.clear();
                  currentStroke = [];
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12),
        ),
        SizedBox(
          height: 30,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? (label == 'Size' ? 49 : 20),
            label: value.toStringAsFixed(1),
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>(
    String label,
    T currentValue,
    List<T> items,
    String Function(T) displayItem,
    ValueChanged<T?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontSize: 13)),

          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<T>(
                value: currentValue,
                items:
                    items.map<DropdownMenuItem<T>>((T value) {
                      return DropdownMenuItem<T>(
                        value: value,
                        child: Text(
                          displayItem(value),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    onChanged(newValue);
                  });
                },
                isDense: true,
                underline: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        SizedBox(
          height: 35,
          child: Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    final bool isSelected = _currentColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
        });
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : [],
        ),

        child:
            color == Colors.white
                ? const Icon(Icons.check, color: Colors.black54, size: 16)
                : null,
      ),
    );
  }
}
