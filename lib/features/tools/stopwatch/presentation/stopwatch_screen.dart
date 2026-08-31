import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/haptics_engine.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  final List<String> _laps = [];
  void _triggerHaptic({bool strong = false}) {
    if (strong) {
      HapticsEngine.heavyImpact();
    } else {
      HapticsEngine.mediumImpact();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {}); // Trigger UI update
      }
    });
  }

  void _startStop() {
    _triggerHaptic(strong: true);
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    } else {
      _stopwatch.start();
      _startTimer();
    }
    setState(() {});
  }

  void _reset() {
    _triggerHaptic();
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    }
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }
  
  void _lap() {
    _triggerHaptic();
    if (_stopwatch.isRunning) {
      final elapsed = _formatDuration(_stopwatch.elapsed);
      setState(() {
        _laps.insert(0, elapsed);
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    String milliseconds = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    
    if (d.inHours > 0) {
      return "${twoDigits(d.inHours)}:$minutes:$seconds.$milliseconds";
    }
    return "$minutes:$seconds.$milliseconds";
  }

  @override
  void dispose() {
    if (_stopwatch.isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.black54;
    final textHint = isDark ? Colors.white38 : Colors.black38;
    final primary = const Color(0xFF6B4EE6);
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Stopwatch', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
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
          // Time Display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular ring
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardBg,
                    border: Border.all(
                      color: primary,
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(isDark ? 0.4 : 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                ),
                
                // Text Time
                Text(
                  _formatDuration(_stopwatch.elapsed),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Laps List
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _laps.isEmpty 
                  ? Center(child: Text('No laps recorded', style: TextStyle(color: textHint)))
                  : ListView.builder(
                      itemCount: _laps.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lap ${_laps.length - index < 10 ? '0' : ''}${_laps.length - index}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
                              ),
                              Text(
                                _laps[index],
                                style: TextStyle(
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reset Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text('Reset', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Lap Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _lap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Lap', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Start / Stop Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startStop,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _stopwatch.isRunning ? const Color(0xFFF95A5A) : const Color(0xFF6B4EE6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(_stopwatch.isRunning ? 'Stop' : 'Start', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
