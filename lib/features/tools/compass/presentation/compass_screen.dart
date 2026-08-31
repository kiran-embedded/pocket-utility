import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/hardware/compass_service.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final CompassService _compassService = CompassService();
  double _heading = 0.0;
  Position? _currentPosition;
  
  bool _hasHapticFeedback = true;
  double _lastHapticHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
    _compassService.startCompass();
    _compassService.headingStream.listen((heading) {
      if (mounted) {
        setState(() => _heading = heading);
        _checkCompassHaptics(heading);
      }
    });
    _compassService.locationStream.listen((position) {
      if (mounted) setState(() => _currentPosition = position);
    });
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _checkCompassHaptics(double newHeading) {
    if (!_hasHapticFeedback) return;
    
    // Trigger haptics every 10 degrees for a mechanical realistic feel
    int oldTick = (_lastHapticHeading / 10).round();
    int newTick = (newHeading / 10).round();
    
    if (oldTick != newTick) {
      // If passing a cardinal direction (N, E, S, W), heavier vibration
      if (newTick % 9 == 0) {
        HapticsEngine.selectionClick(); // Heavier
      } else {
        HapticsEngine.selectionClick(); // Lighter
      }
      _lastHapticHeading = newHeading;
    }
  }

  @override
  void dispose() {
    _compassService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Compass', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: subTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Spacer(),
              
              // Compass Dial
              Center(child: _buildCompassDial(isDarkMode, cardColor, textColor)),
              
              const SizedBox(height: 40),
              
              // Heading Text
              Text(
                '${_heading.toStringAsFixed(0)}° ${_getDirection(_heading)}',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500, color: textColor),
              ),
              
              const Spacer(),
              
              // Location Info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDarkMode) BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Latitude', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('${_currentPosition?.latitude.toStringAsFixed(4) ?? '--'}°', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Longitude', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('${_currentPosition?.longitude.toStringAsFixed(4) ?? '--'}°', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: subTextColor.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Altitude', style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('${_currentPosition?.altitude.toStringAsFixed(0) ?? '--'} m', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassDial(bool isDarkMode, Color cardColor, Color textColor) {
    return Container(
      width: 330,
      height: 330,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cardColor,
        border: Border.all(color: textColor.withOpacity(0.05), width: 8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EE6).withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring (Ticks)
          Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: textColor.withOpacity(0.05), width: 1),
            ),
          ),
          
          // Rotating elements
          Transform.rotate(
            angle: -(_heading * pi / 180),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tick Marks Painter
                CustomPaint(
                  size: const Size(290, 290),
                  painter: _CompassDialPainter(textColor),
                ),
                // Cardinal Directions
                Positioned(top: 10, child: Text('N', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: const Color(0xFFF95A5A)))),
                Positioned(bottom: 10, child: Text('S', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: textColor))),
                Positioned(right: 10, child: Text('E', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: textColor))),
                Positioned(left: 10, child: Text('W', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: textColor))),
              ],
            ),
          ),
          
          // Fixed Needle
          CustomPaint(
            size: const Size(36, 310),
            painter: _CompassNeedlePainter(const Color(0xFFF95A5A), const Color(0xFF6B4EE6)),
          ),
          
          // Red Minute Bar (Lubber Line) pointing straight up (0 degrees on screen)
          Positioned(
            top: 20,
            child: Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF95A5A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Center Pin
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.black : Colors.white,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6B4EE6),
            ),
          ),
        ],
      ),
    );
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    if (heading >= 292.5 && heading < 337.5) return 'NW';
    return '';
  }
}

class _CompassNeedlePainter extends CustomPainter {
  final Color northColor;
  final Color southColor;

  _CompassNeedlePainter(this.northColor, this.southColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // North Needle
    final northPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx, 15)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
      
    final northPaint = Paint()..color = northColor..style = PaintingStyle.fill;
    canvas.drawPath(northPath, northPaint);
    
    // South Needle
    final southPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx, size.height - 15)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
      
    final southPaint = Paint()..color = southColor..style = PaintingStyle.fill;
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassDialPainter extends CustomPainter {
  final Color textColor;
  
  _CompassDialPainter(this.textColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
      
    final majorTickPaint = Paint()
      ..color = textColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final minorTickPaint = Paint()
      ..color = textColor.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 360; i += 2) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 12.0 : (i % 10 == 0 ? 8.0 : 4.0);
      
      final angle = (i - 90) * pi / 180;
      final start = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      
      canvas.drawLine(start, end, isMajor ? majorTickPaint : minorTickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
