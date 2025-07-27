import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  static Future<void> setSelectedCurrency(String currencyCode) async {
    try {
      await _ensureInitialized();
      final success =
          await _prefs?.setString(_currencyKey, currencyCode) ?? false;
      if (success) {
      } else {
        print('Failed to save currency: $currencyCode');
      }
    } catch (e) {
      print('Error saving currency: $e');
    }
  }

  static Future<String?> getSelectedCurrency() async {
    try {
      await _ensureInitialized();
      final currency = _prefs?.getString(_currencyKey);
      print('Retrieved currency from prefs: $currency');
      return currency;
    } catch (e) {
      print('Error getting currency: $e');
      return null;
    }
  }

  static Future<void> clearSelectedCurrency() async {
    try {
      await _ensureInitialized();
      await _prefs?.remove(_currencyKey);
    } catch (e) {
      print('Error clearing currency: $e');
    }
  }
}
