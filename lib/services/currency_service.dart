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
        // Loaded currencies
      }
    } catch (e) {
      // Error loading currencies
    }
  }

  static Future<String?> getSelectedCurrency() async {
    try {
      await _ensureInitialized();
      final currency = _prefs?.getString(_currencyKey);
      // Loading currencies from assets: $currency');
      return currency;
    } catch (e) {
      // Error getting currency
      return null;
    }
  }

  static Future<void> clearSelectedCurrency() async {
    try {
      await _ensureInitialized();
      await _prefs?.remove(_currencyKey);
    } catch (e) {
      // Error clearing currency
    }
  }
}
