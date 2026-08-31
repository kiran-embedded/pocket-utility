import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  // Streams
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magnetSub;
  StreamSubscription<BarometerEvent>? _baroSub;

  // Data history for charts (storing only last 20 points for performance)
  final List<FlSpot> _accelDataX = [];
  final List<FlSpot> _gyroDataX = [];
  final List<FlSpot> _magnetDataX = [];
  
  double _timeCounter = 0;

  bool _hasAccel = false;
  bool _hasGyro = false;
  bool _hasMagnet = false;
  bool _hasBaro = false;

  AccelerometerEvent? _latestAccel;
  GyroscopeEvent? _latestGyro;
  MagnetometerEvent? _latestMagnet;
  BarometerEvent? _latestBaro;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    try {
      _accelSub = accelerometerEventStream().listen((event) {
        if (mounted) {
          setState(() {
            _hasAccel = true;
            _latestAccel = event;
            _addChartPoint(_accelDataX, event.x);
          });
        }
      }, onError: (_) => setState(() => _hasAccel = false));
    } catch (_) {}

    try {
      _gyroSub = gyroscopeEventStream().listen((event) {
        if (mounted) {
          setState(() {
            _hasGyro = true;
            _latestGyro = event;
            _addChartPoint(_gyroDataX, event.x);
          });
        }
      }, onError: (_) => setState(() => _hasGyro = false));
    } catch (_) {}

    try {
      _magnetSub = magnetometerEventStream().listen((event) {
        if (mounted) {
          setState(() {
            _hasMagnet = true;
            _latestMagnet = event;
            _addChartPoint(_magnetDataX, event.x);
          });
        }
      }, onError: (_) => setState(() => _hasMagnet = false));
    } catch (_) {}
    
    try {
      _baroSub = barometerEventStream().listen((event) {
         if (mounted) {
           setState(() {
             _hasBaro = true;
             _latestBaro = event;
           });
         }
      }, onError: (_) => setState(() => _hasBaro = false));
    } catch (_) {}
  }

  void _addChartPoint(List<FlSpot> list, double value) {
    list.add(FlSpot(_timeCounter, value));
    if (list.length > 20) {
      list.removeAt(0);
    }
    _timeCounter += 0.1;
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetSub?.cancel();
    _baroSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Live Sensor Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          if (_hasAccel) _buildSensorCard(
            title: 'Accelerometer',
            unit: 'm/s²',
            icon: Icons.speed,
            color: Colors.purple,
            x: _latestAccel?.x ?? 0,
            y: _latestAccel?.y ?? 0,
            z: _latestAccel?.z ?? 0,
            chartData: _accelDataX,
          ),
          
          if (_hasGyro) _buildSensorCard(
            title: 'Gyroscope',
            unit: 'rad/s',
            icon: Icons.screen_rotation,
            color: Colors.green,
            x: _latestGyro?.x ?? 0,
            y: _latestGyro?.y ?? 0,
            z: _latestGyro?.z ?? 0,
            chartData: _gyroDataX,
          ),
          
          if (_hasMagnet) _buildSensorCard(
            title: 'Magnetometer',
            unit: 'μT',
            icon: Icons.explore,
            color: Colors.orange,
            x: _latestMagnet?.x ?? 0,
            y: _latestMagnet?.y ?? 0,
            z: _latestMagnet?.z ?? 0,
            chartData: _magnetDataX,
          ),
          
          if (_hasBaro) Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Barometer', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_latestBaro?.pressure.toStringAsFixed(1)} hPa'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (!_hasAccel && !_hasGyro && !_hasMagnet && !_hasBaro)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No sensors available on this device.', textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String unit,
    required IconData icon,
    required Color color,
    required double x,
    required double y,
    required double z,
    required List<FlSpot> chartData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildAxisValue('X', x, color),
                        _buildAxisValue('Y', y, color),
                        _buildAxisValue('Z', z, color),
                      ],
                    ),
                  ],
                ),
              ),
              Text(unit, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          if (chartData.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 40,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAxisValue(String axis, double value, Color color) {
    return Row(
      children: [
        Text(axis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
