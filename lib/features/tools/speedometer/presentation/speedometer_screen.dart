import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';

class SpeedometerScreen extends StatefulWidget {
  const SpeedometerScreen({super.key});

  @override
  State<SpeedometerScreen> createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> {
  StreamSubscription<Position>? _positionStream;
  double _speedMps = 0.0;
  bool _isKmph = true;
  double _maxSpeed = 0.0;

  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
    _initLocation();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) HapticsEngine.selectionClick();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _speedMps = position.speed;
          if (_speedMps < 0) _speedMps = 0;
          if (_speedMps > _maxSpeed) _maxSpeed = _speedMps;
        });
      }
    });
  }

  double get _currentSpeed => _isKmph ? _speedMps * 3.6 : _speedMps * 2.23694;
  double get _displayMaxSpeed =>
      _isKmph ? _maxSpeed * 3.6 : _maxSpeed * 2.23694;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxDial = _isKmph ? 240.0 : 160.0;
    double progress = (_currentSpeed / maxDial).clamp(0.0, 1.0);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Speedometer',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Unit Switcher
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnitToggle(
                  'KM/H',
                  _isKmph,
                  cardColor,
                  textColor,
                  subTextColor,
                  primaryColor,
                ),
                const SizedBox(width: 16),
                _buildUnitToggle(
                  'MPH',
                  !_isKmph,
                  cardColor,
                  textColor,
                  subTextColor,
                  primaryColor,
                ),
              ],
            ).animate().slideY(begin: -0.2).fade(),
          ),

          // Flat Gauge
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // The Flat Gauge Painter
                      SizedBox(
                        width: 320,
                        height: 320,
                        child: CustomPaint(
                          painter: SpeedometerPainter(
                            progress: animatedProgress,
                            accentColor: primaryColor,
                            maxSpeed: maxDial,
                            textColor: textColor,
                          ),
                        ),
                      ),

                      // Central Speed Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentSpeed.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -2,
                            ),
                          ),
                          Text(
                            _isKmph ? 'km/h' : 'mph',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack);
                },
              ),
            ),
          ),

          // Max Speed Stats
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: subTextColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    'TOP SPEED',
                    style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_displayMaxSpeed.toStringAsFixed(1)} ${_isKmph ? 'km/h' : 'mph'}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.5, delay: 200.ms).fade(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(
    String label,
    bool isSelected,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _triggerHaptic();
          setState(() => _isKmph = label == 'KM/H');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: subTextColor.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : subTextColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final double maxSpeed;
  final Color textColor;

  SpeedometerPainter({
    required this.progress,
    required this.accentColor,
    required this.maxSpeed,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;

    // Track
    final trackPaint = Paint()
      ..color = textColor.withOpacity(0.05)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Progress
    final progressPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );

    final tickPaint = Paint()
      ..color = textColor.withOpacity(0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final majorTickPaint = Paint()
      ..color = textColor.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    int tickCount = 27;
    for (int i = 0; i <= tickCount; i++) {
      double angle = startAngle + (sweepAngle * i / tickCount);
      bool isMajor = i % 3 == 0;

      double tickLength = isMajor ? 12 : 6;

      Offset inner = Offset(
        center.dx + (radius - 28) * cos(angle),
        center.dy + (radius - 28) * sin(angle),
      );

      Offset outer = Offset(
        center.dx + (radius - 28 - tickLength) * cos(angle),
        center.dy + (radius - 28 - tickLength) * sin(angle),
      );

      canvas.drawLine(inner, outer, isMajor ? majorTickPaint : tickPaint);

      if (isMajor) {
        double currentVal = maxSpeed * (i / tickCount);

        final textPainter = TextPainter(
          text: TextSpan(
            text: currentVal.round().toString(),
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        Offset textPos = Offset(
          center.dx + (radius - 60) * cos(angle) - textPainter.width / 2,
          center.dy + (radius - 60) * sin(angle) - textPainter.height / 2,
        );

        textPainter.paint(canvas, textPos);
      }
    }

    // Needle indicator dot
    if (progress > 0) {
      double currentAngle = startAngle + (sweepAngle * progress);
      Offset dotCenter = Offset(
        center.dx + radius * cos(currentAngle),
        center.dy + radius * sin(currentAngle),
      );

      canvas.drawCircle(dotCenter, 8, Paint()..color = accentColor);
      canvas.drawCircle(dotCenter, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.textColor != textColor ||
        oldDelegate.accentColor != accentColor;
  }
}
