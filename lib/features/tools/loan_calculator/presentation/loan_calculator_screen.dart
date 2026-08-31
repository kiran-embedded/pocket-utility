import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/navigation_utils.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  double _principal = 50000;
  double _interestRate = 5.0; // annual %
  double _termYears = 5;

  double _monthlyPayment = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double p = _principal;
    double r = (_interestRate / 100) / 12; // monthly interest rate
    int n = (_termYears * 12).toInt(); // number of months

    if (r == 0) {
      _monthlyPayment = p / n;
    } else {
      _monthlyPayment = p * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    }
    _totalPayment = _monthlyPayment * n;
    _totalInterest = _totalPayment - p;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final currency = context.watch<CurrencyProvider>().symbol;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  const Text('MONTHLY PAYMENT', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${_monthlyPayment.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Principal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('$currency${_principal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Interest', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('$currency${_totalInterest.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            _buildSlider(
              label: 'Loan Amount',
              value: _principal,
              min: 1000,
              max: 500000,
              prefix: currency,
              onChanged: (val) {
                setState(() {
                  _principal = val;
                  _calculate();
                });
              }
            ),
            const SizedBox(height: 32),
            
            _buildSlider(
              label: 'Interest Rate',
              value: _interestRate,
              min: 0.1,
              max: 25.0,
              suffix: '%',
              divisions: 249,
              onChanged: (val) {
                setState(() {
                  _interestRate = val;
                  _calculate();
                });
              }
            ),
            const SizedBox(height: 32),
            
            _buildSlider(
              label: 'Loan Term',
              value: _termYears,
              min: 1,
              max: 30,
              suffix: ' Years',
              divisions: 29,
              onChanged: (val) {
                setState(() {
                  _termYears = val;
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
    required ValueChanged<double> onChanged,
    int? divisions,
    String prefix = '',
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
            Text('$prefix${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$suffix', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.1),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
