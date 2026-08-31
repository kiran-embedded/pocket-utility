import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../../../../core/animations/animation_modules.dart';
import '../../../../core/utils/flashlight_manager.dart';
import '../../../../core/utils/haptics_engine.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> with SingleTickerProviderStateMixin {
  bool _isOn = false;
  double _brightness = 0.65;
  String _currentMode = 'Normal'; // Normal, SOS, Blink, Strobe
  Timer? _modeTimer;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    FlashlightManager.init();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _modeTimer?.cancel();
    _pulseController.dispose();
    if (_isOn) FlashlightManager.turnOff();
    super.dispose();
  }

  Future<void> _setHardwareTorch(bool on) async {
    try {
      if (on) {
        if (_currentMode == 'Normal') {
          await FlashlightManager.setBrightness(_brightness);
        } else {
          await FlashlightManager.setTorchMode(true);
        }
      } else {
        await FlashlightManager.turnOff();
      }
    } catch (e) {
      debugPrint('Torch error: $e');
    }
  }

  void _toggleFlashlight() {
    HapticsEngine.heavyImpact();
    setState(() {
      _isOn = !_isOn;
    });
    
    if (_isOn) {
      _startCurrentMode();
      _pulseController.repeat(reverse: true);
    } else {
      _stopCurrentMode();
      _setHardwareTorch(false);
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  void _startCurrentMode() {
    _modeTimer?.cancel();
    if (_currentMode == 'Normal') {
      _setHardwareTorch(true);
    } else if (_currentMode == 'Strobe') {
      _modeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _setHardwareTorch(timer.tick % 2 == 0);
      });
    } else if (_currentMode == 'Blink') {
      _modeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        _setHardwareTorch(timer.tick % 2 == 0);
      });
    } else if (_currentMode == 'SOS') {
      _modeTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        _setHardwareTorch(timer.tick % 2 == 0);
      });
    }
  }

  void _stopCurrentMode() {
    _modeTimer?.cancel();
  }

  void _changeMode(String mode) {
    if (_currentMode == mode) {
      mode = 'Normal'; // toggle off mode
    }
    HapticsEngine.selectionClick();
    setState(() {
      _currentMode = mode;
      if (_isOn) {
        _startCurrentMode();
        if (mode == 'Normal') {
          FlashlightManager.setBrightness(_brightness);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = const Color(0xFF8B5CF6); // stunning lavender purple
    final bgColor = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF141415) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context), cardBg, textPrimary, borderColor),
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Flashlight', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary)),
                            const SizedBox(width: 4),
                            Icon(Icons.auto_awesome, color: primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Smart LED Control', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    _buildIconButton(Icons.settings_outlined, () {}, cardBg, textPrimary, borderColor),
                  ],
                ),
              ).applyPremiumFade(delay: 50),
              
              const SizedBox(height: 16),
              
              // READY Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? primary.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withOpacity(0.3)),
                  boxShadow: !isDark ? [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 10)] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: primary, size: 14),
                    const SizedBox(width: 6),
                    Text('READY', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ],
                ),
              ).applyPremiumFade(delay: 100),
              
              const SizedBox(height: 24),
              
              // Main Glowing Button
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient outer glow
                      if (_isOn) 
                        Container(
                          width: 320, height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: primary.withOpacity(0.3 * _pulseController.value), blurRadius: 80, spreadRadius: 20),
                            ],
                          ),
                        ),
                      // Ticks Ring
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: TicksPainter(isDark: isDark, primary: primary, isOn: _isOn),
                      ),
                      // Inner solid ring
                      Container(
                        width: 230, height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 3),
                          color: isDark ? const Color(0xFF1A1A1F) : Colors.white,
                          boxShadow: _isOn ? [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 30, spreadRadius: 2)] : [],
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: _toggleFlashlight,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 200, height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isOn ? primary : (isDark ? const Color(0xFF23232A) : const Color(0xFFE5E2F8)),
                                gradient: _isOn ? LinearGradient(
                                  colors: [primary, primary.withOpacity(0.8)],
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                ) : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 16),
                                  Icon(Icons.flashlight_on_rounded, color: _isOn ? Colors.white : (isDark ? Colors.white70 : primary), size: 64),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isOn ? Colors.white : (isDark ? const Color(0xFF33333A) : Colors.white),
                                    ),
                                    child: Icon(Icons.power_settings_new, color: _isOn ? primary : textSecondary, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ).applyMicroPop(delay: 150),
              
              const SizedBox(height: 32),
              
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOn ? Colors.greenAccent : Colors.grey,
                        boxShadow: _isOn ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 6)] : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Flashlight is ', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(_isOn ? 'ON' : 'OFF', style: TextStyle(color: _isOn ? primary : textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).applyPremiumFade(delay: 200),
              
              const SizedBox(height: 24),
              
              // Brightness Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.light_mode_outlined, color: textPrimary, size: 20),
                              const SizedBox(width: 8),
                              Text('Brightness', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Text('${(_brightness * 100).toInt()}%', style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.light_mode, color: textSecondary, size: 14),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 8,
                                activeTrackColor: primary,
                                inactiveTrackColor: isDark ? const Color(0xFF2A2A2F) : const Color(0xFFF0EDFA),
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                                overlayColor: primary.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _brightness,
                                min: 0.1,
                                max: 1.0,
                                onChanged: (val) {
                                  HapticsEngine.sliderSelection();
                                  setState(() => _brightness = val);
                                  if (_isOn && _currentMode == 'Normal') {
                                    FlashlightManager.setBrightness(val);
                                  }
                                },
                              ),
                            ),
                          ),
                          Icon(Icons.light_mode, color: textSecondary, size: 20),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('10%', style: TextStyle(color: textSecondary, fontSize: 11)),
                            Text('65%', style: TextStyle(color: textSecondary, fontSize: 11)),
                            Text('100%', style: TextStyle(color: textSecondary, fontSize: 11)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ).applyStaggeredSlide(index: 0),
              
              const SizedBox(height: 20),
              
              // Modes Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modes', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildModeBtn('SOS', Icons.more_horiz, _currentMode == 'SOS', primary, isDark, borderColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModeBtn('Blink', Icons.flash_on, _currentMode == 'Blink', primary, isDark, borderColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModeBtn('Strobe', Icons.flare, _currentMode == 'Strobe', primary, isDark, borderColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ).applyStaggeredSlide(index: 1),
              
              const SizedBox(height: 20),
              
              // Status Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusItem('Battery', '72%', Icons.battery_full, primary, textSecondary),
                          Container(width: 1, height: 40, color: borderColor),
                          _buildStatusItem('Safe', 'Camera OK', Icons.verified_user_outlined, primary, textSecondary, isValueSmaller: true),
                          Container(width: 1, height: 40, color: borderColor),
                          _buildStatusItem('Temperature', '28°C\nNormal', Icons.thermostat, primary, textSecondary, isValueSmaller: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ).applyStaggeredSlide(index: 2),
              
              const SizedBox(height: 20),
              
              // Footer Pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: primary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All systems normal', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Flashlight ready to use', style: TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2F) : const Color(0xFFF0EDFA), shape: BoxShape.circle),
                        child: Icon(Icons.arrow_forward_ios, color: primary, size: 12),
                      ),
                    ],
                  ),
                ),
              ).applyStaggeredSlide(index: 3),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, Color bg, Color color, Color border) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: border)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildModeBtn(String title, IconData icon, bool isActive, Color primary, bool isDark, Color border) {
    return GestureDetector(
      onTap: () => _changeMode(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? primary.withOpacity(0.1) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? primary : border),
          boxShadow: isActive && !isDark ? [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 10)] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? primary : (isDark ? Colors.white54 : Colors.black54), size: 24),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: isActive ? primary : (isDark ? Colors.white54 : Colors.black54), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ).applyMicroPop(delay: 0, duration: 150);
  }

  Widget _buildStatusItem(String title, String value, IconData icon, Color primary, Color textSecondary, {bool isValueSmaller = false}) {
    return Column(
      children: [
        Icon(icon, color: primary, size: 24),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value, 
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white, 
            fontSize: isValueSmaller ? 12 : 16, 
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}

class TicksPainter extends CustomPainter {
  final bool isDark;
  final Color primary;
  final bool isOn;
  
  TicksPainter({required this.isDark, required this.primary, required this.isOn});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = isOn ? primary.withOpacity(0.8) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
      
    final int tickCount = 60;
    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * math.pi * i) / tickCount;
      final isLong = i % 5 == 0;
      final tickLength = isLong ? 8.0 : 4.0;
      
      final innerRadius = radius - tickLength;
      final outerRadius = radius;
      
      final x1 = center.dx + innerRadius * math.cos(angle);
      final y1 = center.dy + innerRadius * math.sin(angle);
      
      final x2 = center.dx + outerRadius * math.cos(angle);
      final y2 = center.dy + outerRadius * math.sin(angle);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TicksPainter oldDelegate) {
    return oldDelegate.isOn != isOn || oldDelegate.isDark != isDark;
  }
}
