import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import 'package:pocket_utility/core/utils/flashlight_manager.dart';
import '../../../core/utils/navigation_utils.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  bool _isSosActive = false;
  bool _isStrobeActive = false;
  Timer? _flashTimer;
  bool _flashState = false;
  
  late AnimationController _pulseController;
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic({bool heavy = false}) {
    if (_hasHapticFeedback) {
      if (heavy) {
        HapticsEngine.heavyImpact();
      } else {
        HapticsEngine.selectionClick();
      }
    }
  }

  void _toggleSos() async {
    _triggerHaptic(heavy: true);
    setState(() {
      _isSosActive = !_isSosActive;
      _isStrobeActive = false;
    });
    
    _flashTimer?.cancel();
    await _turnOffFlash();
    
    if (_isSosActive) {
      _startSosSequence();
    }
  }

  void _toggleStrobe() async {
    _triggerHaptic(heavy: true);
    setState(() {
      _isStrobeActive = !_isStrobeActive;
      _isSosActive = false;
    });
    
    _flashTimer?.cancel();
    await _turnOffFlash();
    
    if (_isStrobeActive) {
      _flashTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _flashState = !_flashState;
        if (_flashState) {
          _turnOnFlash();
        } else {
          _turnOffFlash();
        }
      });
    }
  }

  void _startSosSequence() async {
    List<int> pattern = [
      200, 200, 200, 200, 200, 600, // 3 short
      600, 200, 600, 200, 600, 600, // 3 long
      200, 200, 200, 200, 200, 1000 // 3 short
    ];
    
    int index = 0;
    
    void nextStep() {
      if (!_isSosActive) return;
      
      if (index % 2 == 0) {
        _turnOnFlash();
      } else {
        _turnOffFlash();
      }
      
      _flashTimer = Timer(Duration(milliseconds: pattern[index]), () {
        index = (index + 1) % pattern.length;
        nextStep();
      });
    }
    
    nextStep();
  }

  Future<void> _turnOnFlash() async {
    try { await FlashlightManager.setTorchMode(true); } catch (_) {}
  }

  Future<void> _turnOffFlash() async {
    try { await FlashlightManager.setTorchMode(false); } catch (_) {}
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _turnOffFlash();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Emergency', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Flat Clean SOS Button
            Expanded(
              flex: 3,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleSos,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isSosActive ? primary : cardColor,
                          border: Border.all(
                            color: _isSosActive ? primary : primary.withOpacity(0.3), 
                            width: _isSosActive ? 8 : 4
                          ),
                          boxShadow: _isSosActive ? [
                            BoxShadow(
                              color: primary.withOpacity(_pulseController.value * 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ] : [],
                        ),
                        child: Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: _isSosActive ? Colors.white : primary,
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
              ),
            ),
            
            // Flat Strobe Button
            Expanded(
              flex: 1,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleStrobe,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: _isStrobeActive ? primary : cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isStrobeActive ? primary : primary.withOpacity(0.3),
                        width: _isStrobeActive ? 0 : 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: _isStrobeActive ? Colors.white : primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'STROBE',
                          style: TextStyle(
                            color: _isStrobeActive ? Colors.white : primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2, delay: 200.ms).fade(),
              ),
            ),
            
            // Info Text
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Uses device flashlight to signal for help.',
                style: TextStyle(color: Theme.of(context).disabledColor),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
