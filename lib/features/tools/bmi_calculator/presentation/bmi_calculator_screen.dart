import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_utils.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  bool _isMetric = true;
  double _weight = 70; // kg or lbs
  double _height = 170; // cm or inches

  double _bmi = 0;
  String _category = '';
  Color _categoryColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    if (_isMetric) {
      double heightM = _height / 100;
      _bmi = _weight / (heightM * heightM);
    } else {
      _bmi = (_weight / (_height * _height)) * 703;
    }

    if (_bmi < 18.5) {
      _category = 'Underweight';
      _categoryColor = Colors.blue;
    } else if (_bmi >= 18.5 && _bmi < 25) {
      _category = 'Normal';
      _categoryColor = Colors.green;
    } else if (_bmi >= 25 && _bmi < 30) {
      _category = 'Overweight';
      _categoryColor = Colors.orange;
    } else {
      _category = 'Obese';
      _categoryColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Metric (kg/cm)')),
                ButtonSegment<bool>(value: false, label: Text('Imperial (lb/in)')),
              ],
              selected: {_isMetric},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isMetric = newSelection.first;
                  // Convert existing values for convenience
                  if (_isMetric) {
                    _weight = _weight * 0.453592;
                    _height = _height * 2.54;
                  } else {
                    _weight = _weight / 0.453592;
                    _height = _height / 2.54;
                  }
                  _calculate();
                });
              },
            ),
            const SizedBox(height: 48),
            
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: _categoryColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                ],
                border: Border.all(color: _categoryColor.withOpacity(0.5), width: 4),
              ),
              child: Column(
                children: [
                  const Text('YOUR BMI', style: TextStyle(color: Colors.grey, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: TextStyle(color: _categoryColor, fontSize: 64, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _categoryColor, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      _category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            _buildSlider(
              label: 'Height',
              value: _height,
              min: _isMetric ? 50 : 20,
              max: _isMetric ? 250 : 100,
              unit: _isMetric ? 'cm' : 'in',
              onChanged: (val) {
                setState(() {
                  _height = val;
                  _calculate();
                });
              }
            ),
            const SizedBox(height: 32),
            
            _buildSlider(
              label: 'Weight',
              value: _weight,
              min: _isMetric ? 10 : 22,
              max: _isMetric ? 300 : 660,
              unit: _isMetric ? 'kg' : 'lbs',
              onChanged: (val) {
                setState(() {
                  _weight = val;
                  _calculate();
                });
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 12,
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.1),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
