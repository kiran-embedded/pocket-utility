import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/animations/animation_modules.dart';

class HotTeaWidget extends StatefulWidget {
  final bool isDark;
  const HotTeaWidget({super.key, required this.isDark});

  @override
  State<HotTeaWidget> createState() => _HotTeaWidgetState();
}

class _HotTeaWidgetState extends State<HotTeaWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The cropped tea cup image
          Image.asset(
            'assets/images/tea_cup.png',
            fit: BoxFit.contain,
            width: 80, 
            height: 80,
          ),
          // Animated Steam Shader overlay
          Positioned(
            top: -10,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(60, 60),
                  painter: SteamPainter(_controller.value, widget.isDark),
                );
              },
            ),
          ),
        ],
      ).applyPremiumFade(delay: 200),
    );
  }
}

class SteamPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  SteamPainter(this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    _drawSteamCurve(canvas, size, paint, progress, 0);
    _drawSteamCurve(canvas, size, paint, progress + 0.33, 15);
    _drawSteamCurve(canvas, size, paint, progress + 0.66, 30);
  }

  void _drawSteamCurve(Canvas canvas, Size size, Paint paint, double progress, double offsetX) {
    final p = progress % 1.0;
    final path = Path();
    
    double startY = size.height - (p * size.height * 1.5);
    double startX = offsetX + math.sin(p * math.pi * 4) * 8;
    
    path.moveTo(startX, startY);
    path.quadraticBezierTo(
      startX + 10, startY - 15,
      startX - 5, startY - 30,
    );
    path.quadraticBezierTo(
      startX - 15, startY - 45,
      startX + 5, startY - 60,
    );

    // Fade out at the top
    final alpha = ((1.0 - p) * 255).clamp(0, 255).toInt();
    paint.color = paint.color.withAlpha(alpha);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SteamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
