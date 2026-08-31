import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';
import '../../../../core/utils/navigation_utils.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final String _apiUrl = 'https://open.er-api.com/v6/latest/';
  
  Map<String, dynamic> _rates = {};
  List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'SGD']; // Defaults while loading
  bool _isLoading = true;
  bool _hasError = false;
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _result = '';
  
  // A map of popular currency symbols
  final Map<String, String> _currencySymbols = {
    'USD': '\$', 'EUR': '€', 'GBP': '£', 'INR': '₹', 'JPY': '¥', 
    'CAD': 'C\$', 'AUD': 'A\$', 'CHF': 'CHF', 'CNY': '¥', 'SGD': 'S\$',
    'AED': 'د.إ', 'SAR': '﷼', 'BRL': 'R\$', 'MXN': '\$', 'ZAR': 'R',
    'RUB': '₽', 'TRY': '₺', 'NGN': '₦', 'KRW': '₩'
  };

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }
  
  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final response = await http.get(Uri.parse('$_apiUrl$_fromCurrency'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _rates = data['rates'];
          _currencies = _rates.keys.toList();
          _currencies.sort();
          _calculate();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load rates');
      }
    } catch (e) {
      debugPrint('Currency API Error: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _calculate() {
    if (_rates.isEmpty) return;
    
    double? amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() => _result = '---');
      return;
    }
    
    // The rates map is based on _fromCurrency being the base (1.0).
    final double rate = _rates[_toCurrency] ?? 0.0;
    final double output = amount * rate;
    
    setState(() {
      // Format with thousands separator and 2 decimal places
      _result = output.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    });
  }
  
  Future<void> _swapCurrencies() async {
    HapticsEngine.selectionClick();
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _isLoading = true; // Need to fetch new base rates
    });
    await _fetchRates();
  }

  void _showCurrencyPicker(bool isFrom) {
    HapticsEngine.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primary = Theme.of(context).primaryColor;
            
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select Currency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _currencies.length,
                      itemBuilder: (context, index) {
                        final currency = _currencies[index];
                        final symbol = _currencySymbols[currency] ?? '';
                        final isSelected = isFrom ? currency == _fromCurrency : currency == _toCurrency;
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? primary : (isDark ? Colors.grey[800] : Colors.grey[200]),
                            child: Text(symbol.isNotEmpty ? symbol : currency[0], style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
                          ),
                          title: Text(currency, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          trailing: isSelected ? Icon(Icons.check_circle, color: primary) : null,
                          onTap: () {
                            HapticsEngine.selectionClick();
                            Navigator.pop(context);
                            setState(() {
                              if (isFrom) {
                                _fromCurrency = currency;
                                _fetchRates(); // Re-fetch base rates
                              } else {
                                _toCurrency = currency;
                                _calculate();
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_hasError)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 16),
                      Expanded(child: Text('Failed to fetch live rates. Please check your internet connection.', style: TextStyle(color: isDark ? Colors.red[200] : Colors.red[800]))),
                    ],
                  ),
                ).applyPremiumFade(delay: 50),
              
              // Top Currency Card
              _buildCurrencyCard(
                currency: _fromCurrency,
                isFrom: true,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                  onChanged: (val) {
                    _calculate();
                  },
                ),
                primary: primary,
              ).applyPremiumFade(delay: 100),
              
              // Swap Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: GestureDetector(
                    onTap: _swapCurrencies,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: _isLoading 
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                        : Icon(Icons.swap_vert, color: primary, size: 28),
                    ),
                  ),
                ),
              ).applyMicroPop(delay: 150),
              
              // Bottom Currency Card
              _buildCurrencyCard(
                currency: _toCurrency,
                isFrom: false,
                child: Text(
                  _result.isEmpty ? '---' : _result,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
                  overflow: TextOverflow.ellipsis,
                ),
                primary: primary,
              ).applyPremiumFade(delay: 200),
              
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Exchange rates are updated daily from the European Central Bank and other global sources.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ).applyStaggeredSlide(index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard({required String currency, required bool isFrom, required Widget child, required Color primary}) {
    final symbol = _currencySymbols[currency] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(isFrom ? 0.4 : 0.1), width: isFrom ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showCurrencyPicker(isFrom),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currency, style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (symbol.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(symbol, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}
