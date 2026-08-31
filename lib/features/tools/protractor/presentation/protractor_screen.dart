import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/animations/animation_modules.dart';

class ProtractorScreen extends StatefulWidget {
  const ProtractorScreen({super.key});

  @override
  State<ProtractorScreen> createState() => _ProtractorScreenState();
}

class _ProtractorScreenState extends State<ProtractorScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  
  double _angle1 = 0.0;
  double _angle2 = math.pi / 4; 
  
  bool _useCamera = true;
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) HapticsEngine.selectionClick();
  }

  double get _measuredAngleDegrees {
    double diff = (_angle2 - _angle1).abs();
    if (diff > math.pi) diff = 2 * math.pi - diff;
    return diff * (180 / math.pi);
  }

  void _updateAngle(Offset center, Offset touch, bool isAngle1) {
    double dx = touch.dx - center.dx;
    double dy = touch.dy - center.dy;
    double newAngle = math.atan2(dy, dx);
    
    setState(() {
      if (isAngle1) {
        _angle1 = newAngle;
      } else {
        _angle2 = newAngle;
      }
    });
    
    if ((_measuredAngleDegrees % 5) < 0.5) {
      _triggerHaptic();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _isDarkMode ? Colors.black : const Color(0xFFF9FAFB);
    final fallbackBgColor = _isDarkMode ? Colors.black : const Color(0xFFF0F2F5);
    final textColor = _useCamera ? Colors.white : (_isDarkMode ? Colors.white : Colors.black87);
    final subTextColor = _useCamera ? Colors.white70 : (_isDarkMode ? Colors.white70 : Colors.black54);
    final dialColor = _useCamera ? Colors.white : (_isDarkMode ? Colors.white : Colors.black87);
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
        title: Text('Protractor', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_useCamera ? Icons.videocam_off : Icons.videocam, color: textColor),
            onPressed: () {
              setState(() => _useCamera = !_useCamera);
              _triggerHaptic();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background 
          if (_useCamera)
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {},
            )
          else
            Container(color: fallbackBgColor),
            
          // Protractor UI
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double size = math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
                Offset center = Offset(size / 2, size / 2);
                
                return SizedBox(
                  width: size,
                  height: size,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      double d1 = math.sqrt(math.pow(details.localPosition.dx - (center.dx + (size/2 - 20) * math.cos(_angle1)), 2) + math.pow(details.localPosition.dy - (center.dy + (size/2 - 20) * math.sin(_angle1)), 2));
                      double d2 = math.sqrt(math.pow(details.localPosition.dx - (center.dx + (size/2 - 20) * math.cos(_angle2)), 2) + math.pow(details.localPosition.dy - (center.dy + (size/2 - 20) * math.sin(_angle2)), 2));
                      _updateAngle(center, details.localPosition, d1 < d2);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(size, size),
                          painter: ProtractorPainter(
                            angle1: _angle1,
                            angle2: _angle2,
                            color: primaryColor,
                            dialColor: dialColor,
                          ),
                        ),
                        _buildHandle(center, _angle1, size / 2, primaryColor, _isDarkMode, _useCamera),
                        _buildHandle(center, _angle2, size / 2, primaryColor, _isDarkMode, _useCamera),
                      ],
                    ),
                  ),
                ).applyPremiumFade(delay: 50);
              },
            ),
          ),
          
          // Premium Angle Display
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.85),
                          primaryColor.withOpacity(0.65),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_measuredAngleDegrees.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 54, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ANGLE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8), 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ).applyPremiumFade(delay: 150),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHandle(Offset center, double angle, double radius, Color color, bool isDarkMode, bool useCamera) {
    double handleRadius = radius - 20; 
    double dx = center.dx + handleRadius * math.cos(angle);
    double dy = center.dy + handleRadius * math.sin(angle);
    
    return Positioned(
      left: dx - 30,
      top: dy - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 8),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class ProtractorPainter extends CustomPainter {
  final double angle1;
  final double angle2;
  final Color color;
  final Color dialColor;

  ProtractorPainter({required this.angle1, required this.angle2, required this.color, required this.dialColor});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    final dialPaint = Paint()
      ..color = dialColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, dialPaint);
    
    final tickPaint = Paint()
      ..color = dialColor
      ..strokeWidth = 1;
      
    for (int i = 0; i < 360; i += 5) {
      double a = i * (math.pi / 180);
      bool isMajor = i % 30 == 0;
      bool isMedium = i % 10 == 0 && !isMajor;
      
      double tickLength = isMajor ? 18 : (isMedium ? 12 : 6);
      
      Offset p1 = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      Offset p2 = Offset(
        center.dx + (radius - tickLength) * math.cos(a),
        center.dy + (radius - tickLength) * math.sin(a),
      );
      
      tickPaint.strokeWidth = isMajor ? 2.5 : 1.5;
      tickPaint.color = isMajor ? dialColor : dialColor.withOpacity(0.5);
      canvas.drawLine(p1, p2, tickPaint);
      
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(text: '$i°', style: TextStyle(color: dialColor.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        Offset textPos = Offset(
          center.dx + (radius - 40) * math.cos(a) - textPainter.width / 2,
          center.dy + (radius - 40) * math.sin(a) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textPos);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    canvas.drawLine(
      center, 
      Offset(center.dx + radius * math.cos(angle1), center.dy + radius * math.sin(angle1)), 
      linePaint,
    );
    canvas.drawLine(
      center, 
      Offset(center.dx + radius * math.cos(angle2), center.dy + radius * math.sin(angle2)), 
      linePaint,
    );
    
    final arcPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    double startAngle = angle1;
    double sweepAngle = angle2 - angle1;
    
    if (sweepAngle > math.pi) sweepAngle -= 2 * math.pi;
    if (sweepAngle < -math.pi) sweepAngle += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius / 3.5), 
      startAngle, 
      sweepAngle, 
      true, 
      arcPaint,
    );
    
    final arcBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius / 3.5), 
      startAngle, 
      sweepAngle, 
      false, 
      arcBorderPaint,
    );
    
    canvas.drawCircle(center, 8, Paint()..color = color);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.angle1 != angle1 || oldDelegate.angle2 != angle2 || oldDelegate.dialColor != dialColor;
  }
}
