import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final TextEditingController _billController = TextEditingController();
  double _tipPercentage = 15.0;
  int _splitCount = 1;

  double _totalTip = 0;
  double _totalBill = 0;
  double _perPerson = 0;

  void _calculate() {
    double bill = double.tryParse(_billController.text) ?? 0;
    _totalTip = bill * (_tipPercentage / 100);
    _totalBill = bill + _totalTip;
    _perPerson = _splitCount > 0 ? _totalBill / _splitCount : 0;
    setState(() {});
  }

  void _incrementSplit() {
    setState(() {
      _splitCount++;
      _calculate();
    });
    HapticsEngine.selectionClick();
  }

  void _decrementSplit() {
    if (_splitCount > 1) {
      setState(() {
        _splitCount--;
        _calculate();
      });
      HapticsEngine.selectionClick();
    }
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final currency = context.watch<CurrencyProvider>().symbol;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Calculator'),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  const Text('TOTAL PER PERSON', style: TextStyle(color: Colors.grey, letterSpacing: 1.5, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${_perPerson.toStringAsFixed(2)}',
                    style: TextStyle(color: primaryColor, fontSize: 56, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Bill', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('$currency${_totalBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Tip', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('$currency${_totalTip.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculate(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Bill Amount',
                prefixText: '$currency ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 32),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tip Percentage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                    Text('${_tipPercentage.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withOpacity(0.1),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _tipPercentage,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (val) {
                      setState(() {
                        _tipPercentage = val;
                        _calculate();
                      });
                    },
                    onChangeEnd: (_) => HapticsEngine.selectionClick(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Split', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decrementSplit,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: primaryColor,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),
                    Text('$_splitCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _incrementSplit,
                      icon: const Icon(Icons.add_circle_outline),
                      color: primaryColor,
                      iconSize: 32,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
