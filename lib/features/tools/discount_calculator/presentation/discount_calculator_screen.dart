import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';


class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  double _discountPercentage = 20.0;
  
  double _finalPrice = 0;
  double _savedAmount = 0;

  void _calculate() {
    double price = double.tryParse(_priceController.text) ?? 0;
    _savedAmount = price * (_discountPercentage / 100);
    _finalPrice = price - _savedAmount;
    setState(() {});
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final currency = context.watch<CurrencyProvider>().symbol;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
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
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
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
                  const Text('FINAL PRICE', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${_finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(color: Colors.white24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Original Price', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('$currency${(double.tryParse(_priceController.text) ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('You Save', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('$currency${_savedAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculate(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Original Price',
                prefixText: '$currency ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.local_offer),
              ),
            ),
            const SizedBox(height: 32),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('${_discountPercentage.toInt()}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withOpacity(0.1),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withOpacity(0.2),
                    valueIndicatorColor: primaryColor,
                  ),
                  child: Slider(
                    value: _discountPercentage,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${_discountPercentage.toInt()}%',
                    onChanged: (val) {
                      setState(() {
                        _discountPercentage = val;
                        _calculate();
                      });
                    },
                    onChangeEnd: (_) => HapticsEngine.selectionClick(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [10, 15, 20, 25, 30, 40, 50, 75].map((percent) => 
                ActionChip(
                  label: Text('$percent%'),
                  backgroundColor: _discountPercentage == percent ? primaryColor : Theme.of(context).cardColor,
                  labelStyle: TextStyle(color: _discountPercentage == percent ? Colors.white : null),
                  onPressed: () {
                    setState(() {
                      _discountPercentage = percent.toDouble();
                      _calculate();
                    });
                    HapticsEngine.selectionClick();
                  }
                )
              ).toList(),
            )
          ],
        ),
      ),
    );
  }
}
