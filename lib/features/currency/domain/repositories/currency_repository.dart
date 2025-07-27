import '../entities/currency.dart';

abstract class CurrencyRepository {
  /// Returns a list of all available currencies
  Future<List<Currency>> getAllCurrencies();

  /// Returns a list of most used currencies
  Future<List<Currency>> getMostUsedCurrencies();

  /// Sets the selected currency
  Future<void> setSelectedCurrency(Currency currency);

}
