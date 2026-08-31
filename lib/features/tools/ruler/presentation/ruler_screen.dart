import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class RulerScreen extends StatefulWidget {
  const RulerScreen({super.key});

  @override
  State<RulerScreen> createState() => _RulerScreenState();
}

class _RulerScreenState extends State<RulerScreen> {
  double _pixelsPerCm = 60.0; 
  bool _isMetric = true;
  
  double _markerPosition = 150.0;
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic({bool light = true}) {
    if (_hasHapticFeedback) {
      HapticsEngine.selectionClick();
    }
  }

  double get _currentMeasurement {
    if (_isMetric) return _markerPosition / _pixelsPerCm;
    return _markerPosition / (_pixelsPerCm * 2.54);
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB);
    final rulerBgColor = _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final lineColor = _isDarkMode ? Colors.amber : const Color(0xFF6B4EE6);
    final shadowColor = _isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: Text('Ruler', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // The Premium Ruler Canvas
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: rulerBgColor,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(10, 0),
                ),
                BoxShadow(
                  color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  blurRadius: 2,
                  offset: const Offset(-2, 0),
                ),
              ],
              border: Border(
                right: BorderSide(color: _isDarkMode ? Colors.black : Colors.black12, width: 4),
              ),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(120, constraints.maxHeight),
                      painter: RulerPainter(
                        pixelsPerCm: _pixelsPerCm,
                        isMetric: _isMetric,
                        lineColor: lineColor,
                        textColor: textColor,
                      ),
                    );
                  },
                ),
                // Premium Edge Highlight
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideX(begin: -0.5, curve: Curves.easeOutCubic),
          
          // Measurement Area & Slider
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _markerPosition += details.delta.dy;
                  if (_markerPosition < 0) _markerPosition = 0;
                });
                if (_markerPosition.toInt() % 10 == 0) _triggerHaptic();
              },
              child: Container(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Measurement Display
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentMeasurement.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _triggerHaptic(light: false);
                                setState(() => _isMetric = !_isMetric);
                              },
                              child: Text(
                                _isMetric ? 'CENTIMETERS' : 'INCHES',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate(key: ValueKey(_isMetric)).fade().scale(),
                    ),
                    
                    // Sliding Marker Indicator
                    Positioned(
                      top: _markerPosition - 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          // Pointer triangle
                          CustomPaint(
                            size: const Size(20, 40),
                            painter: TrianglePainter(color: Colors.redAccent),
                          ),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final double pixelsPerCm;
  final bool isMetric;
  final Color lineColor;
  final Color textColor;

  RulerPainter({
    required this.pixelsPerCm,
    required this.isMetric,
    required this.lineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2;

    final double unitPixels = isMetric ? pixelsPerCm : pixelsPerCm * 2.54;
    final int subDivisions = isMetric ? 10 : 16;
    
    for (double y = 0; y < size.height; y += (unitPixels / subDivisions)) {
      double lineLength = 20; // Minor tick
      bool isMajor = false;
      bool isMedium = false;

      // Determine tick length
      double currentUnitPos = y / unitPixels;
      double remainder = currentUnitPos - currentUnitPos.floorToDouble();
      
      if (remainder < 0.001 || remainder > 0.999) {
        lineLength = 60; // Major tick
        isMajor = true;
      } else if ((isMetric && (remainder - 0.5).abs() < 0.001) || 
                 (!isMetric && (remainder - 0.5).abs() < 0.001)) {
        lineLength = 40; // Medium tick (halfway)
        isMedium = true;
      } else if (!isMetric && ((remainder - 0.25).abs() < 0.001 || (remainder - 0.75).abs() < 0.001)) {
        lineLength = 30; // Quarter tick for inches
      }
      
      paint.strokeWidth = isMajor ? 3 : (isMedium ? 2 : 1);
      paint.color = isMajor ? lineColor : lineColor.withOpacity(0.5);

      // Draw line from right edge
      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width - lineLength, y),
        paint,
      );

      // Draw text for major ticks
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: currentUnitPos.round().toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        canvas.save();
        canvas.translate(size.width - lineLength - 10, y);
        canvas.rotate(-3.14159 / 2); // Rotate text 90 degrees CCW
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.pixelsPerCm != pixelsPerCm || oldDelegate.isMetric != isMetric;
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
