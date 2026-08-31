import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _x = 0.0;
  double _y = 0.0;
  double _calibratedX = 0.0;
  double _calibratedY = 0.0;
  
  bool _isSurfaceMode = true; // True for circular surface level, False for horizontal tubular bubble level
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _accelSub = accelerometerEventStream().listen((event) {
      if (mounted) {
        setState(() {
          // Accelerometer returns gravity vector
          // On a flat surface face up, Z is ~9.8, X and Y are ~0
          // If we tilt phone left/right, X changes
          // If we tilt phone forward/back, Y changes
          
          // Apply low-pass filter to smooth the bubble
          _x = _x * 0.8 + (event.x - _calibratedX) * 0.2;
          _y = _y * 0.8 + (event.y - _calibratedY) * 0.2;
        });
      }
    });
  }

  void _calibrate() {
    setState(() {
      _calibratedX += _x;
      _calibratedY += _y;
      _x = 0;
      _y = 0;
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  bool get _isBalanced {
    return _x.abs() < 0.2 && _y.abs() < 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Mode Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildModeToggleButton('Surface', true),
                _buildModeToggleButton('Bubble', false),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: _isSurfaceMode ? _buildSurfaceLevel() : _buildTubularLevel(),
            ),
          ),
          
          // Coordinates
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCoordinateChip('X', _x),
              const SizedBox(width: 16),
              _buildCoordinateChip('Y', _y),
            ],
          ),
          const SizedBox(height: 16),
          
          // Balanced Indicator
          Text(
            _isBalanced ? 'Balanced' : 'Adjust',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isBalanced ? Colors.green : Theme.of(context).disabledColor,
            ),
          ),
          
          // Bottom Controls
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _calibrate,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Calibrate'),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _soundEnabled = !_soundEnabled;
                    });
                  },
                  icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModeToggleButton(String title, bool isSurface) {
    final isSelected = _isSurfaceMode == isSurface;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSurfaceMode = isSurface;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurfaceLevel() {
    // Determine bubble position. Max value for x/y roughly 9.8.
    // We map -9.8..9.8 to -radius..radius of the circle
    final double maxSensorValue = 9.8;
    final double circleRadius = 120.0;
    
    // Clamp the values to keep bubble inside the circle visually
    double mappedX = (_x / maxSensorValue) * circleRadius * 2;
    double mappedY = (_y / maxSensorValue) * circleRadius * 2;
    
    // Constrain to circle
    double distance = math.sqrt(mappedX * mappedX + mappedY * mappedY);
    if (distance > circleRadius) {
      mappedX = (mappedX / distance) * circleRadius;
      mappedY = (mappedY / distance) * circleRadius;
    }

    return Container(
      width: circleRadius * 2 + 40,
      height: circleRadius * 2 + 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _isBalanced ? Colors.green : Theme.of(context).primaryColor, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Crosshairs
          Container(
            width: double.infinity,
            height: 1,
            color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
          ),
          Container(
            width: 1,
            height: double.infinity,
            color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
          ),
          // Inner target circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _isBalanced ? Colors.green : Theme.of(context).disabledColor, width: 2),
            ),
          ),
          // The Bubble
          Transform.translate(
            offset: Offset(-mappedX, mappedY), // Invert X for correct visual feeling based on tilt
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isBalanced ? Colors.green : Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: (_isBalanced ? Colors.green : Theme.of(context).primaryColor).withValues(alpha: 0.5),
                    blurRadius: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTubularLevel() {
    // Horizontal tubular level
    final double maxSensorValue = 9.8;
    final double tubeWidth = 250.0;
    
    double mappedX = (_x / maxSensorValue) * (tubeWidth / 2);
    if (mappedX > tubeWidth / 2 - 20) mappedX = tubeWidth / 2 - 20;
    if (mappedX < -tubeWidth / 2 + 20) mappedX = -tubeWidth / 2 + 20;

    return Container(
      width: tubeWidth,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _isBalanced ? Colors.green : Theme.of(context).primaryColor, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Target lines
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 2, height: 60, color: Theme.of(context).disabledColor),
              const SizedBox(width: 40),
              Container(width: 2, height: 60, color: Theme.of(context).disabledColor),
            ],
          ),
          // Bubble
          Transform.translate(
            offset: Offset(-mappedX, 0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isBalanced ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateChip(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(1) + '°', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
