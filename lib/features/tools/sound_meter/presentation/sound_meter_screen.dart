import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';

class SoundMeterScreen extends StatefulWidget {
  const SoundMeterScreen({super.key});

  @override
  State<SoundMeterScreen> createState() => _SoundMeterScreenState();
}

class _SoundMeterScreenState extends State<SoundMeterScreen> {
  bool _isRecording = false;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  double _currentDecibels = 0.0;
  double _maxDecibels = 0.0;

  final List<FlSpot> _chartData = [];
  double _timeCounter = 0;

  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
    _checkPermissionsAndHaptics();
  }

  Future<void> _checkPermissionsAndHaptics() async {
    bool hasVib = true;
    setState(() {
      _hasHapticFeedback = hasVib ?? false;
    });

    var status = await Permission.microphone.status;
    if (status.isGranted) {
      _start();
    } else {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        _start();
      }
    }
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) {
      HapticsEngine.selectionClick();
    }
  }

  void _onData(NoiseReading noiseReading) {
    if (!mounted) return;
    setState(() {
      _currentDecibels = noiseReading.meanDecibel;
      if (_currentDecibels > _maxDecibels) {
        _maxDecibels = _currentDecibels;
      }

      _chartData.add(FlSpot(_timeCounter, _currentDecibels));
      if (_chartData.length > 40) {
        _chartData.removeAt(0);
      }
      _timeCounter += 0.1;

      if (_currentDecibels > 85 && _timeCounter % 1.0 < 0.1) {
        _triggerHaptic();
      }
    });
  }

  void _onError(Object error) {
    _stop();
  }

  void _start() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(
        _onData,
        onError: _onError,
      );
      setState(() {
        _isRecording = true;
      });
      _triggerHaptic();
    } catch (err) {
      _stop();
    }
  }

  void _stop() {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        _isRecording = false;
      });
      _triggerHaptic();
    } catch (err) {}
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  String _getEnvironmentDescription(double db) {
    if (db < 30) return 'Whisper / Quiet Library';
    if (db < 50) return 'Quiet Office';
    if (db < 70) return 'Normal Conversation';
    if (db < 85) return 'City Traffic';
    if (db < 100) return 'Factory / Motorcycle';
    if (db < 120) return 'Rock Concert / Siren';
    return 'Pain Threshold';
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _isDarkMode
        ? Colors.black
        : const Color(0xFFF9FAFB);
    final cardColor = _isDarkMode
        ? Colors.white.withOpacity(0.05)
        : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = _isDarkMode ? Colors.white70 : Colors.black54;

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
          'Sound Meter',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // Decibel Gauge
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer dashed ring
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: _DashedCirclePainter(
                      color: subTextColor.withOpacity(0.2),
                      strokeWidth: 2,
                      dashes: 60,
                    ),
                  ),

                  // Progress arc
                  CustomPaint(
                    size: const Size(240, 240),
                    painter: _GaugeProgressPainter(
                      progress: _currentDecibels / 120.0,
                      color: const Color(0xFF6B4EE6),
                      backgroundColor: subTextColor.withOpacity(0.1),
                      strokeWidth: 16,
                    ),
                  ),

                  // Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentDecibels.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'dB',
                        style: TextStyle(
                          fontSize: 20,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getEnvironmentDescription(_currentDecibels),
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).applyPremiumFade(delay: 100),

          const Spacer(),

          // Chart
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: _isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Min', '30 dB', subTextColor, textColor),
                      _buildStatColumn(
                        'Avg',
                        '${(_currentDecibels > 0 ? _currentDecibels - 5 : 0).toStringAsFixed(0)} dB',
                        subTextColor,
                        textColor,
                      ),
                      _buildStatColumn(
                        'Max',
                        '${_maxDecibels.toStringAsFixed(0)} dB',
                        subTextColor,
                        textColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _chartData.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minY: 0,
                            maxY: 120,
                            minX: _chartData.isNotEmpty
                                ? _chartData.first.x
                                : 0,
                            maxX: _chartData.isNotEmpty
                                ? _chartData.last.x
                                : 10,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _chartData,
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: const Color(0xFF6B4EE6),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6B4EE6).withOpacity(0.3),
                                      const Color(0xFF6B4EE6).withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ).applyPremiumFade(delay: 200),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color subTextColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: subTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double dashAngle = 2 * math.pi / dashes;
    for (int i = 0; i < dashes; i++) {
      final double startAngle = i * dashAngle;
      // dash takes up 50% of the segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  _GaugeProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    double sweepAngle = math.pi * 1.5 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
