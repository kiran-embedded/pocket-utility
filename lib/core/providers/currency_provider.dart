import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static const _key = 'selected_currency';

  static const List<Map<String, String>> currencies = [
    {'symbol': '₹', 'name': 'Indian Rupee', 'code': 'INR'},
    {'symbol': '\$', 'name': 'US Dollar', 'code': 'USD'},
    {'symbol': '€', 'name': 'Euro', 'code': 'EUR'},
    {'symbol': '£', 'name': 'British Pound', 'code': 'GBP'},
    {'symbol': '¥', 'name': 'Japanese Yen', 'code': 'JPY'},
    {'symbol': '¥', 'name': 'Chinese Yuan', 'code': 'CNY'},
    {'symbol': '₩', 'name': 'South Korean Won', 'code': 'KRW'},
    {'symbol': 'A\$', 'name': 'Australian Dollar', 'code': 'AUD'},
    {'symbol': 'C\$', 'name': 'Canadian Dollar', 'code': 'CAD'},
    {'symbol': 'CHF', 'name': 'Swiss Franc', 'code': 'CHF'},
    {'symbol': 'AED', 'name': 'UAE Dirham', 'code': 'AED'},
    {'symbol': 'SAR', 'name': 'Saudi Riyal', 'code': 'SAR'},
    {'symbol': 'SGD', 'name': 'Singapore Dollar', 'code': 'SGD'},
    {'symbol': 'MYR', 'name': 'Malaysian Ringgit', 'code': 'MYR'},
    {'symbol': 'BRL', 'name': 'Brazilian Real', 'code': 'BRL'},
    {'symbol': 'MXN', 'name': 'Mexican Peso', 'code': 'MXN'},
    {'symbol': 'ZAR', 'name': 'South African Rand', 'code': 'ZAR'},
    {'symbol': '₺', 'name': 'Turkish Lira', 'code': 'TRY'},
    {'symbol': '₽', 'name': 'Russian Ruble', 'code': 'RUB'},
    {'symbol': '₦', 'name': 'Nigerian Naira', 'code': 'NGN'},
  ];

  String _symbol = '₹';
  String _code = 'INR';
  String _name = 'Indian Rupee';

  String get symbol => _symbol;
  String get code => _code;
  String get name => _name;

  CurrencyProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'INR';
    final found = currencies.firstWhere(
      (c) => c['code'] == saved,
      orElse: () => currencies.first,
    );
    _symbol = found['symbol']!;
    _code = found['code']!;
    _name = found['name']!;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    final found = currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => currencies.first,
    );
    _symbol = found['symbol']!;
    _code = found['code']!;
    _name = found['name']!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    notifyListeners();
  }
}
