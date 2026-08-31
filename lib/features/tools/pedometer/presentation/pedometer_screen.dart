import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/utils/navigation_utils.dart';

class PedometerScreen extends StatefulWidget {
  const PedometerScreen({super.key});

  @override
  State<PedometerScreen> createState() => _PedometerScreenState();
}

class _PedometerScreenState extends State<PedometerScreen> {
  int _stepCount = 0;
  bool _isTracking = false;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  
  // Basic peak detection variables
  double _threshold = 1.5;
  DateTime _lastStepTime = DateTime.now();

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    if (_isTracking) {
      _accelSubscription?.cancel();
      setState(() => _isTracking = false);
    } else {
      setState(() => _isTracking = true);
      _accelSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        // Calculate magnitude vector
        double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        
        if (magnitude > _threshold) {
          DateTime now = DateTime.now();
          if (now.difference(_lastStepTime).inMilliseconds > 300) {
            setState(() {
              _stepCount++;
              _lastStepTime = now;
            });
          }
        }
      });
    }
  }

  void _resetSteps() {
    setState(() {
      _stepCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // Calculate simple stats based on steps
    double distanceKm = _stepCount * 0.000762; // roughly 0.762 meters per step
    double calories = _stepCount * 0.04; // roughly 0.04 kcal per step

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _resetSteps,
            tooltip: 'Reset',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert), 
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
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_walk, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        '$_stepCount',
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text(
                        'STEPS',
                        style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Distance', '${distanceKm.toStringAsFixed(2)} km', Icons.map),
                  _buildStatCard('Calories', '${calories.toStringAsFixed(0)} kcal', Icons.local_fire_department),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleTracking,
                  icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
                  label: Text(_isTracking ? 'PAUSE TRACKING' : 'START TRACKING'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: _isTracking ? Colors.orange : primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: App must remain open to track steps accurately.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
