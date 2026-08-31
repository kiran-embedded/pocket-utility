import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _workDuration = 25 * 60;
  static const int _breakDuration = 5 * 60;
  
  int _timeLeft = _workDuration;
  bool _isRunning = false;
  bool _isWorkPhase = true;
  Timer? _timer;

  void _toggleTimer() {
    HapticsEngine.heavyImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          _timer?.cancel();
          HapticsEngine.heavyImpact();
          setState(() {
            _isRunning = false;
            _isWorkPhase = !_isWorkPhase;
            _timeLeft = _isWorkPhase ? _workDuration : _breakDuration;
          });
        }
      });
    }
  }

  void _resetTimer() {
    HapticsEngine.selectionClick();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkPhase ? _workDuration : _breakDuration;
    });
  }

  void _switchPhase(bool isWork) {
    if (_isWorkPhase == isWork) return;
    HapticsEngine.selectionClick();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkPhase = isWork;
      _timeLeft = _isWorkPhase ? _workDuration : _breakDuration;
    });
  }

  String get _timeString {
    int m = _timeLeft ~/ 60;
    int s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    int total = _isWorkPhase ? _workDuration : _breakDuration;
    return 1 - (_timeLeft / total);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDark ? Colors.black : const Color(0xFFF9FAFB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;
    
    // Modern colors for Pomodoro
    final workColor = isDark ? const Color(0xFFFF5252) : const Color(0xFFFF3B30);
    final breakColor = isDark ? const Color(0xFF64FFDA) : const Color(0xFF34C759);
    final accentColor = _isWorkPhase ? workColor : breakColor;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pomodoro', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textSecondary), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glassmorphic Phase Switcher
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPhaseButton('Work', true, workColor, isDark),
                    _buildPhaseButton('Break', false, breakColor, isDark),
                  ],
                ),
              ).applyPremiumFade(delay: 50),
              
              const SizedBox(height: 64),
              
              // Beautiful Circular Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 16,
                      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ).applyPremiumFade(delay: 100),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isWorkPhase ? 'FOCUS' : 'RELAX',
                        style: TextStyle(fontSize: 18, color: accentColor, letterSpacing: 6, fontWeight: FontWeight.bold),
                      ).applyPremiumFade(delay: 150),
                      const SizedBox(height: 8),
                      Text(
                        _timeString,
                        style: TextStyle(
                          fontSize: 76, 
                          fontWeight: FontWeight.w300,
                          color: textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ).applyPremiumFade(delay: 200),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 80),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _resetTimer,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      ),
                      child: Icon(Icons.replay, size: 28, color: textSecondary),
                    ),
                  ).applyPremiumFade(delay: 250),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow_rounded, 
                        size: 40, 
                        color: Colors.white,
                      ),
                    ),
                  ).applyPremiumFade(delay: 300).applyMicroPop(delay: 300),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 60,
                    height: 60,
                    // Placeholder to balance the layout symmetrically
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseButton(String title, bool isWork, Color color, bool isDark) {
    bool isSelected = _isWorkPhase == isWork;
    return GestureDetector(
      onTap: () => _switchPhase(isWork),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
