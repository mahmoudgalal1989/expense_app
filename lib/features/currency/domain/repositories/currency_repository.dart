import '../entities/currency.dart';

abstract class CurrencyRepository {
  /// Returns a list of all available currencies
  Future<List<Currency>> getAllCurrencies();

  /// Searches for currencies by code or name
  /// [query] The search term to match against currency code or name
  Future<List<Currency>> searchCurrencies(String query);

  /// Sets the selected currency
  Future<void> setSelectedCurrency(Currency currency);
}
