import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class CoinFlipperScreen extends StatefulWidget {
  const CoinFlipperScreen({super.key});

  @override
  State<CoinFlipperScreen> createState() => _CoinFlipperScreenState();
}

class _CoinFlipperScreenState extends State<CoinFlipperScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  bool _isHeads = true;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(begin: 0, end: pi * 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc)
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlipping = false);
        HapticsEngine.heavyImpact(); // Haptic impact
      }
    });
  }

  void _flipCoin() {
    if (_isFlipping) return;
    
    HapticsEngine.selectionClick(); // Tap haptic
    setState(() {
      _isFlipping = true;
      _isHeads = Random().nextBool();
    });
    
    _controller.reset();
    
    // Determine the end rotation so it lands on correct face
    double endRotation = pi * (10 + (_isHeads ? 0 : 1)); 
    _animation = Tween<double>(begin: 0, end: endRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc)
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Flipper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _flipCoin,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_animation.value),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFDB931)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                      const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
                    ],
                    border: Border.all(color: Colors.amber.shade200, width: 8),
                  ),
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      // Keep text readable depending on flip state
                      transform: Matrix4.rotationX(_animation.value % (pi * 2) > pi / 2 && _animation.value % (pi * 2) < 3 * pi / 2 ? pi : 0),
                      child: Text(
                        _animation.value % (pi * 2) > pi / 2 && _animation.value % (pi * 2) < 3 * pi / 2 ? 'TAILS' : 'HEADS',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          shadows: const [Shadow(color: Colors.white, blurRadius: 2, offset: Offset(1, 1))],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            
            Text(
              _isFlipping ? 'Flipping...' : 'It\'s ${_isHeads ? 'Heads' : 'Tails'}!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _isFlipping ? Colors.grey : Theme.of(context).primaryColor),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: _flipCoin,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                ),
                child: const Text('FLIP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
