import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/navigation_utils.dart';

class UnitPriceScreen extends StatefulWidget {
  const UnitPriceScreen({super.key});

  @override
  State<UnitPriceScreen> createState() => _UnitPriceScreenState();
}

class _UnitPriceScreenState extends State<UnitPriceScreen> {
  final TextEditingController _priceAController = TextEditingController();
  final TextEditingController _quantityAController = TextEditingController();
  final TextEditingController _priceBController = TextEditingController();
  final TextEditingController _quantityBController = TextEditingController();

  double _unitPriceA = 0;
  double _unitPriceB = 0;
  String _winner = '';

  void _calculate() {
    double priceA = double.tryParse(_priceAController.text) ?? 0;
    double qtyA = double.tryParse(_quantityAController.text) ?? 0;
    double priceB = double.tryParse(_priceBController.text) ?? 0;
    double qtyB = double.tryParse(_quantityBController.text) ?? 0;

    setState(() {
      _unitPriceA = qtyA > 0 ? priceA / qtyA : 0;
      _unitPriceB = qtyB > 0 ? priceB / qtyB : 0;

      if (_unitPriceA == 0 && _unitPriceB == 0) {
        _winner = '';
      } else if (_unitPriceA > 0 && (_unitPriceB == 0 || _unitPriceA < _unitPriceB)) {
        _winner = 'A';
      } else if (_unitPriceB > 0 && (_unitPriceA == 0 || _unitPriceB < _unitPriceA)) {
        _winner = 'B';
      } else {
        _winner = 'EQUAL';
      }
    });
  }

  @override
  void dispose() {
    _priceAController.dispose();
    _quantityAController.dispose();
    _priceBController.dispose();
    _quantityBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Price Comparison'),
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
            _buildItemCard('Item A', _priceAController, _quantityAController, _winner == 'A', Colors.blue),
            const SizedBox(height: 16),
            const Center(child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey))),
            const SizedBox(height: 16),
            _buildItemCard('Item B', _priceBController, _quantityBController, _winner == 'B', Colors.deepPurple),
            
            if (_winner.isNotEmpty) ...[
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _winner == 'EQUAL' ? Colors.grey.shade800 : (_winner == 'A' ? Colors.blue.shade700 : Colors.deepPurple.shade700),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text('BEST VALUE', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      _winner == 'EQUAL' ? 'Both are Equal' : 'Item $_winner is Cheaper',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    if (_winner != 'EQUAL') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Saves you ${(100 - ((_winner == 'A' ? _unitPriceA : _unitPriceB) / (_winner == 'A' ? _unitPriceB : _unitPriceA) * 100)).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ]
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(String title, TextEditingController priceCtrl, TextEditingController qtyCtrl, bool isWinner, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isWinner ? accent : Colors.transparent, width: 3),
        boxShadow: [
          BoxShadow(color: isWinner ? accent.withOpacity(0.3) : Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isWinner ? accent : null)),
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
                  child: const Text('WINNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculate(),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculate(),
                  decoration: InputDecoration(
                    labelText: 'Quantity / Weight',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Unit Price: ${(priceCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) ? (double.tryParse(priceCtrl.text) ?? 0) / ((double.tryParse(qtyCtrl.text) ?? 1) == 0 ? 1 : (double.tryParse(qtyCtrl.text) ?? 1)) : 0.00} per unit',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          )
        ],
      ),
    );
  }
}
