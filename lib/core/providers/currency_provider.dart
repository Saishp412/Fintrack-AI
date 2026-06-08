import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _symbol = '₹';
  String _code = 'INR';

  String get symbol => _symbol;
  String get code => _code;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _symbol = prefs.getString('currency_symbol') ?? '₹';
    _code = prefs.getString('currency_code') ?? 'INR';
    notifyListeners();
  }

  Future<void> setCurrency(String symbol, String code) async {
    _symbol = symbol;
    _code = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    await prefs.setString('currency_code', code);
    notifyListeners();
  }
}
