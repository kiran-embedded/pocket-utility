import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class RandomPickerScreen extends StatefulWidget {
  const RandomPickerScreen({super.key});

  @override
  State<RandomPickerScreen> createState() => _RandomPickerScreenState();
}

class _RandomPickerScreenState extends State<RandomPickerScreen> with SingleTickerProviderStateMixin {
  int _min = 1;
  int _max = 100;
  int _currentResult = 0;
  bool _isSpinning = false;
  
  bool _hasHapticFeedback = true;
  
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
    
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _spinController.addListener(() {
      if (_spinController.isAnimating) {
        setState(() {
          _currentResult = _min + Random().nextInt(_max - _min + 1);
        });
        
        if ((_spinController.value * 100).toInt() % 5 == 0) {
          _triggerHaptic();
        }
      }
    });
    
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _currentResult = _min + Random().nextInt(_max - _min + 1);
        });
        _triggerHaptic(strong: true);
      }
    });
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
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

  void _generateRandom() {
    if (_isSpinning) return;
    
    if (_min >= _max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Min value must be less than Max value')),
      );
      return;
    }
    
    setState(() {
      _isSpinning = true;
    });
    
    _spinController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Random Picker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Display with sparkling animation
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 2),
                  ),
                  child: Center(
                    child: _isSpinning ? Text(
                      _currentResult == 0 ? '?' : _currentResult.toString(),
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: primaryColor.withOpacity(0.5),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .shake(hz: 10, curve: Curves.easeInOut)
                      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)) 
                    : Text(
                      _currentResult == 0 ? '?' : _currentResult.toString(),
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ).animate(key: ValueKey(_currentResult))
                     .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.easeOutBack)
                     .shimmer(duration: 1200.ms, color: Colors.amber.shade200, angle: pi / 4),
                  ),
                ).animate().slideY(begin: -0.1).fade(),
              ),
              
              const SizedBox(height: 32),
              
              // Min / Max Inputs
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard('Min', _min, (val) => setState(() => _min = val), cardColor, textColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputCard('Max', _max, (val) => setState(() => _max = val), cardColor, textColor),
                  ),
                ],
              ).animate().slideY(begin: 0.1, delay: 100.ms).fade(),
              
              const SizedBox(height: 32),
              
              // Flat Clean Generate Button
              GestureDetector(
                onTap: _generateRandom,
                onTapDown: (_) => _triggerHaptic(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _isSpinning ? Theme.of(context).disabledColor : primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _isSpinning ? 'SPINNING...' : 'PICK RANDOM',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, int value, Function(int) onChanged, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null) onChanged(parsed);
            },
          ),
        ],
      ),
    );
  }
}
