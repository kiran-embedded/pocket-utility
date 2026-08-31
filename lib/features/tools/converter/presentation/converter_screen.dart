import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final List<String> _categories = ['Length', 'Weight', 'Temperature'];
  String _selectedCategory = 'Length';
  
  final Map<String, List<String>> _units = {
    'Length': ['Meters', 'Kilometers', 'Centimeters', 'Miles', 'Feet', 'Inches'],
    'Weight': ['Kilograms', 'Grams', 'Pounds', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  String _fromUnit = 'Meters';
  String _toUnit = 'Kilometers';
  
  final TextEditingController _inputController = TextEditingController(text: '1');
  String _result = '0.001';
  
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) HapticsEngine.selectionClick();
  }

  void _calculate() {
    double? input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = '---');
      return;
    }

    double output = 0;
    if (_selectedCategory == 'Length') {
      double meters = _toMeters(input, _fromUnit);
      output = _fromMeters(meters, _toUnit);
    } else if (_selectedCategory == 'Weight') {
      double kg = _toKg(input, _fromUnit);
      output = _fromKg(kg, _toUnit);
    } else if (_selectedCategory == 'Temperature') {
      output = _convertTemp(input, _fromUnit, _toUnit);
    }

    setState(() {
      if (output % 1 == 0) {
        _result = output.toInt().toString();
      } else {
        _result = output.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    });
  }

  // --- Conversion Logic ---
  double _toMeters(double val, String unit) {
    switch(unit) {
      case 'Kilometers': return val * 1000;
      case 'Centimeters': return val / 100;
      case 'Miles': return val * 1609.34;
      case 'Feet': return val * 0.3048;
      case 'Inches': return val * 0.0254;
      default: return val;
    }
  }
  double _fromMeters(double val, String unit) {
    switch(unit) {
      case 'Kilometers': return val / 1000;
      case 'Centimeters': return val * 100;
      case 'Miles': return val / 1609.34;
      case 'Feet': return val / 0.3048;
      case 'Inches': return val / 0.0254;
      default: return val;
    }
  }
  double _toKg(double val, String unit) {
    switch(unit) {
      case 'Grams': return val / 1000;
      case 'Pounds': return val * 0.453592;
      case 'Ounces': return val * 0.0283495;
      default: return val;
    }
  }
  double _fromKg(double val, String unit) {
    switch(unit) {
      case 'Grams': return val * 1000;
      case 'Pounds': return val / 0.453592;
      case 'Ounces': return val / 0.0283495;
      default: return val;
    }
  }
  double _convertTemp(double val, String from, String to) {
    if (from == to) return val;
    double c = val;
    if (from == 'Fahrenheit') c = (val - 32) * 5 / 9;
    if (from == 'Kelvin') c = val - 273.15;
    
    if (to == 'Celsius') return c;
    if (to == 'Fahrenheit') return (c * 9 / 5) + 32;
    if (to == 'Kelvin') return c + 273.15;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
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
          // Category Selector (Filled, 3D pill style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      _triggerHaptic();
                      setState(() {
                        _selectedCategory = cat;
                        _fromUnit = _units[cat]!.first;
                        _toUnit = _units[cat]![1];
                        _calculate();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ).animate().slideY(begin: -0.2, curve: Curves.easeOutQuad).fade(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // FROM Section
                  _buildUnitSection(
                    title: 'From',
                    unit: _fromUnit,
                    isInput: true,
                    onUnitChange: (newUnit) {
                      if (newUnit != null) {
                        setState(() { _fromUnit = newUnit; _calculate(); });
                      }
                    },
                  ).animate().slideX(begin: -0.2, delay: 100.ms).fade(),
                  
                  // Swap Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        _triggerHaptic();
                        setState(() {
                          final temp = _fromUnit;
                          _fromUnit = _toUnit;
                          _toUnit = temp;
                          _calculate();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.swap_vert, size: 32, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                  
                  // TO Section
                  _buildUnitSection(
                    title: 'To',
                    unit: _toUnit,
                    isInput: false,
                    onUnitChange: (newUnit) {
                      if (newUnit != null) {
                        setState(() { _toUnit = newUnit; _calculate(); });
                      }
                    },
                  ).animate().slideX(begin: 0.2, delay: 150.ms).fade(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSection({
    required String title,
    required String unit,
    required bool isInput,
    required ValueChanged<String?> onUnitChange,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).disabledColor, fontWeight: FontWeight.bold)),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: unit,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  items: _units[_selectedCategory]!.map((u) {
                    return DropdownMenuItem(value: u, child: Text(u));
                  }).toList(),
                  onChanged: (val) {
                    _triggerHaptic();
                    onUnitChange(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isInput)
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => _calculate(),
            )
          else
            Text(
              _result,
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
