import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../dashboard/presentation/main_layout.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding = prefs.getBool('onboarding_complete') ?? false;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasCompletedOnboarding ? const MainLayout() : const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Background waves could go here, for now it is solid color
          
          // Floating background sparkles
          Positioned(
            bottom: size.height * 0.25,
            left: size.width * 0.2,
            child: SvgPicture.string(_sparkleSvg, width: 12, colorFilter: const ColorFilter.mode(Color(0xFFB1AEF7), BlendMode.srcIn))
                .animate(onPlay: (controller) => controller.repeat())
                .fade(duration: 2000.ms).then().fadeOut(duration: 2000.ms),
          ),
          Positioned(
            bottom: size.height * 0.15,
            right: size.width * 0.1,
            child: SvgPicture.string(_sparkleSvg, width: 16, colorFilter: const ColorFilter.mode(Color(0xFFB1AEF7), BlendMode.srcIn))
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 2000.ms),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Central Orbit System
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dotted Orbit Ring
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: DottedCirclePainter(),
                        ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms, delay: 200.ms).rotate(duration: 20000.ms, curve: Curves.linear),
                        
                        // Orbiting Icons
                        _buildOrbitIcon(Icons.flashlight_on, const Color(0xFF6B4EE6), 0),
                        _buildOrbitIcon(Icons.search, const Color(0xFF2EBD59), math.pi / 4),
                        _buildOrbitIcon(Icons.straighten, const Color(0xFFF95A5A), math.pi / 2),
                        _buildOrbitIcon(Icons.calculate, const Color(0xFFFF9500), 3 * math.pi / 4),
                        _buildOrbitIcon(Icons.qr_code, const Color(0xFF8A2BE2), math.pi),
                        _buildOrbitIcon(Icons.mic, const Color(0xFFE94B7C), 5 * math.pi / 4),
                        _buildOrbitIcon(Icons.timer, const Color(0xFFF5B000), 3 * math.pi / 2),
                        _buildOrbitIcon(Icons.explore, const Color(0xFF2D78FF), 7 * math.pi / 4),

                        // Center Logo Box
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B4EE6).withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Vector tools inside logo
                              Positioned(
                                top: 15,
                                child: SvgPicture.string(_logoToolsSvg, width: 90),
                              ),
                              // Purple gradient pocket
                              Positioned(
                                bottom: -2,
                                child: SvgPicture.string(_logoPocketSvg, width: 142),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.easeOutBack, begin: const Offset(0.5, 0.5))
                        .fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Text Section
                  Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6B4EE6), Color(0xFFE94B7C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'POCKET',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().slideY(begin: 0.5, duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).fadeIn(),
                      
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE94B7C), Color(0xFFFF9500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'UTILITY',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().slideY(begin: 0.5, duration: 600.ms, delay: 300.ms, curve: Curves.easeOut).fadeIn(),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 1, color: const Color(0xFF6B4EE6).withOpacity(0.5)),
                          const SizedBox(width: 8),
                          SvgPicture.string(_sparkleSvg, width: 16, colorFilter: const ColorFilter.mode(Color(0xFF6B4EE6), BlendMode.srcIn)),
                          const SizedBox(width: 8),
                          Container(width: 40, height: 1, color: const Color(0xFF6B4EE6).withOpacity(0.5)),
                        ],
                      ).animate().scaleX(begin: 0, duration: 600.ms, delay: 500.ms).fadeIn(),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'All the tools you need,\nright in your pocket.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54, // Changed to be visible on light background
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fade(duration: 800.ms, delay: 600.ms),
                    ],
                  ),
                  const Spacer(),
                  // Pagination dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(true),
                      const SizedBox(width: 8),
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(false),
                    ],
                  ).animate().fade(duration: 800.ms, delay: 800.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF6B4EE6) : const Color(0xFF6B4EE6).withOpacity(0.2),
      ),
    );
  }

  Widget _buildOrbitIcon(IconData icon, Color color, double angle) {
    final double radius = 130;
    return Transform.translate(
      offset: Offset(radius * math.cos(angle - math.pi / 2), radius * math.sin(angle - math.pi / 2)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    ).animate().scale(delay: (400 + (angle * 200)).ms, duration: 600.ms, curve: Curves.easeOutBack).fadeIn();
  }
}


class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double dashWidth = 4, dashSpace = 6;
    double circumference = 2 * math.pi * radius;
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    double angleSweep = 2 * math.pi / dashCount;
    
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * angleSweep,
          angleSweep,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const String _sparkleSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 0C12 0 12 10 24 12C24 12 14 12 12 24C12 24 12 14 0 12C0 12 10 12 12 0Z" fill="currentColor"/>
</svg>
''';

const String _logoPocketSvg = '''
<svg viewBox="0 0 142 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="pocketGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#8E6EF7" />
      <stop offset="100%" stop-color="#5530E3" />
    </linearGradient>
  </defs>
  <path d="M5,0 C5,0 71,20 137,0 C140,0 142,5 142,20 C142,60 112,80 71,80 C30,80 0,60 0,20 C0,5 2,0 5,0 Z" fill="url(#pocketGrad)"/>
  <path d="M71 30C71 30 71 45 85 48C85 48 71 48 71 62C71 62 71 48 57 48C57 48 71 48 71 30Z" fill="white"/>
</svg>
''';

const String _logoToolsSvg = '''
<svg viewBox="0 0 100 80" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M30 10 L35 20 M50 5 L50 15 M70 10 L65 20" stroke="#7E5BF2" stroke-width="3" stroke-linecap="round"/>
  <rect x="42" y="20" width="16" height="60" rx="2" fill="#1C1E3A"/>
  <path d="M38 20 L62 20 L60 30 L40 30 Z" fill="#292D53"/>
  <circle cx="50" cy="45" r="3" fill="white"/>
  <g transform="translate(15, 35) rotate(-15)">
    <circle cx="15" cy="15" r="14" fill="#E8E9EE" stroke="#1C1E3A" stroke-width="2"/>
    <circle cx="15" cy="15" r="2" fill="#1C1E3A"/>
    <path d="M15 4 L18 15 L15 26 L12 15 Z" fill="#1C1E3A"/>
    <path d="M15 4 L18 15 L15 15 Z" fill="#F95A5A"/>
    <circle cx="15" cy="-2" r="3" stroke="#1C1E3A" stroke-width="2" fill="none"/>
  </g>
  <g transform="translate(60, 25) rotate(30)">
    <rect x="13" y="20" width="4" height="25" rx="2" fill="#1C1E3A"/>
    <circle cx="15" cy="10" r="10" fill="white" stroke="#1C1E3A" stroke-width="3"/>
    <circle cx="12" cy="7" r="3" fill="#E8E9EE"/>
  </g>
  <g transform="translate(65, 55) rotate(45)">
    <rect x="0" y="0" width="12" height="25" rx="2" fill="#E8E9EE" stroke="#1C1E3A" stroke-width="2"/>
    <path d="M3 5 L7 5 M3 10 L9 10 M3 15 L7 15" stroke="#1C1E3A" stroke-width="2" stroke-linecap="round"/>
  </g>
</svg>
''';
