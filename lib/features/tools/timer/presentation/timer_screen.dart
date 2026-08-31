import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 30;
  int _selectedSeconds = 0;
  
  int _totalSeconds = 1800; // 30 minutes default
  int _remainingSeconds = 1800;
  
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    setState(() {
      _hasHapticFeedback = hasVib ?? false;
    });
  }

  void _triggerHaptic({bool strong = false}) {
    if (_hasHapticFeedback) {
      if (strong) {
        HapticsEngine.heavyImpact();
      } else {
        HapticsEngine.selectionClick();
      }
    }
  }

  void _startTimer() {
    _triggerHaptic();
    if (!_isPaused && !_isRunning) {
      _totalSeconds = (_selectedHours * 3600) + (_selectedMinutes * 60) + _selectedSeconds;
      _remainingSeconds = _totalSeconds;
    }
    
    if (_remainingSeconds > 0) {
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isPaused = false;
            _triggerHaptic(strong: true);
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _triggerHaptic();
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _cancelTimer() {
    _triggerHaptic();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
  }
  
  void _setQuickTime(int minutes) {
    _triggerHaptic();
    setState(() {
      _selectedHours = minutes ~/ 60;
      _selectedMinutes = minutes % 60;
      _selectedSeconds = 0;
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isPaused = false;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final bgColor = isDark ? Colors.black : const Color(0xFFF9FAFB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Timer', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          
          // Visual Display / Picker
          Expanded(
            child: _isRunning || _isPaused 
                ? _buildRunningTimer(isDark, primary).applyPremiumFade(delay: 50)
                : _buildTimePicker(isDark).applyPremiumFade(delay: 50),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Pills
          if (!_isRunning && !_isPaused)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickPill('1 min', 1, isDark, primary).applyStaggeredSlide(index: 0),
                const SizedBox(width: 12),
                _buildQuickPill('5 min', 5, isDark, primary).applyStaggeredSlide(index: 1),
                const SizedBox(width: 12),
                _buildQuickPill('10 min', 10, isDark, primary).applyStaggeredSlide(index: 2),
                const SizedBox(width: 12),
                _buildQuickPill('15 min', 15, isDark, primary).applyStaggeredSlide(index: 3),
              ],
            ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: _isRunning || _isPaused
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelTimer,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text('Cancel', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        ).applyPremiumFade(delay: 150),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _isRunning ? Colors.orange : primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(_isRunning ? 'Pause' : 'Resume', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ).applyPremiumFade(delay: 200),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ).applyPremiumFade(delay: 150),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningTimer(bool isDark, Color primary) {
    double progress = _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
              color: primary,
            ),
          ),
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : Colors.black87,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPickerColumn('Hours', 24, _selectedHours, (val) => setState(() => _selectedHours = val), isDark),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(':', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, color: isDark ? Colors.white : Colors.black87)),
        ),
        _buildPickerColumn('Min', 60, _selectedMinutes, (val) => setState(() => _selectedMinutes = val), isDark),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(':', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, color: isDark ? Colors.white : Colors.black87)),
        ),
        _buildPickerColumn('Sec', 60, _selectedSeconds, (val) => setState(() => _selectedSeconds = val), isDark),
      ],
    );
  }

  Widget _buildPickerColumn(String label, int max, int currentValue, ValueChanged<int> onChanged, bool isDark) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 64,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                _triggerHaptic();
                onChanged(index);
              },
              controller: FixedExtentScrollController(initialItem: currentValue),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: max,
                builder: (context, index) {
                  bool isSelected = index == currentValue;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: isSelected ? 48 : 36,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected 
                            ? (isDark ? Colors.white : Colors.black87) 
                            : (isDark ? Colors.white24 : Colors.black38),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuickPill(String text, int minutes, bool isDark, Color primary) {
    return GestureDetector(
      onTap: () => _setQuickTime(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? primary.withOpacity(0.15) : primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ).applyMicroPop(delay: 0, duration: 150),
    );
  }
}
