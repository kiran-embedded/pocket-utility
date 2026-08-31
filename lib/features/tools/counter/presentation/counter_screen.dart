import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with SingleTickerProviderStateMixin {
  int _count = 0;
  bool _hasHapticFeedback = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
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

  void _increment() {
    _triggerHaptic();
    _animController.forward(from: 0.0);
    setState(() {
      _count++;
    });
  }

  void _decrement() {
    if (_count > 0) {
      _triggerHaptic();
      _animController.forward(from: 0.0);
      setState(() {
        _count--;
      });
    }
  }

  void _reset() {
    _triggerHaptic(heavy: true);
    setState(() {
      _count = 0;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Counter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animController.value * 0.05),
                    child: Text(
                      '$_count',
                      style: TextStyle(
                        fontSize: 140,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.remove,
                  onTap: _decrement,
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  iconColor: textColor,
                ),
                _buildActionButton(
                  icon: Icons.refresh,
                  onTap: _reset,
                  color: isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red.shade100,
                  iconColor: Colors.red,
                  size: 64,
                ),
                _buildActionButton(
                  icon: Icons.add,
                  onTap: _increment,
                  color: primaryColor,
                  iconColor: Colors.white,
                  size: 80,
                ),
              ],
            ).animate().slideY(begin: 0.5, delay: 200.ms).fade(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    double size = 72,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: size * 0.4),
        ),
      ),
    );
  }
}
