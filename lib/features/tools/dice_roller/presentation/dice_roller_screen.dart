import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  int _diceCount = 1;
  List<int> _diceValues = [1];
  bool _isRolling = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _animation = Tween<double>(begin: 0, end: pi * 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isRolling = false);
        HapticsEngine.heavyImpact(); // Hard impact
      }
    });
  }

  void _rollDice() {
    if (_isRolling) return;
    HapticsEngine.selectionClick(); // Tap
    setState(() {
      _isRolling = true;
      for (int i = 0; i < _diceCount; i++) {
        _diceValues[i] = _random.nextInt(6) + 1;
      }
    });
    
    _controller.reset();
    _controller.forward();
  }

  void _updateDiceCount(int count) {
    setState(() {
      _diceCount = count;
      _diceValues = List.filled(count, 1);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDice(int value) {
    // Generate dots based on value
    List<Widget> dots = [];
    switch (value) {
      case 1: dots = [_dot()]; break;
      case 2: dots = [_dot(align: Alignment.topLeft), _dot(align: Alignment.bottomRight)]; break;
      case 3: dots = [_dot(align: Alignment.topLeft), _dot(), _dot(align: Alignment.bottomRight)]; break;
      case 4: dots = [_dot(align: Alignment.topLeft), _dot(align: Alignment.topRight), _dot(align: Alignment.bottomLeft), _dot(align: Alignment.bottomRight)]; break;
      case 5: dots = [_dot(align: Alignment.topLeft), _dot(align: Alignment.topRight), _dot(), _dot(align: Alignment.bottomLeft), _dot(align: Alignment.bottomRight)]; break;
      case 6: dots = [_dot(align: Alignment.topLeft), _dot(align: Alignment.topRight), _dot(align: Alignment.centerLeft), _dot(align: Alignment.centerRight), _dot(align: Alignment.bottomLeft), _dot(align: Alignment.bottomRight)]; break;
    }

    return Transform.rotate(
      angle: _animation.value,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(5, 5)),
            BoxShadow(color: Colors.white, blurRadius: 10, offset: const Offset(-5, -5)),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: dots,
        ),
      ),
    );
  }

  Widget _dot({Alignment align = Alignment.center}) {
    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _diceValues.reduce((a, b) => a + b);
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
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
              child: Wrap(
                alignment: WrapAlignment.center,
                children: _diceValues.map((v) => _buildDice(v)).toList(),
              ),
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('TOTAL', style: TextStyle(color: Colors.grey, letterSpacing: 2, fontSize: 14)),
                  Text(
                    _isRolling ? '?' : '$total',
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 24),
                  
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('1 Dice')),
                      ButtonSegment(value: 2, label: Text('2 Dice')),
                      ButtonSegment(value: 3, label: Text('3 Dice')),
                      ButtonSegment(value: 4, label: Text('4 Dice')),
                    ],
                    selected: {_diceCount},
                    onSelectionChanged: (set) => _updateDiceCount(set.first),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _rollDice,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                      ),
                      child: const Text('ROLL DICE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
