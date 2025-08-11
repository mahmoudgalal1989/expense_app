import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_app/core/error/exceptions.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/data/models/currency_model.dart';
import 'package:expense_app/features/currency/data/datasources/currency_local_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyLocalDataSource localDataSource;
  final SharedPreferences prefs;

  static const String _selectedCurrencyKey = 'selected_currency';

  List<CurrencyModel>? _cachedModels;

  CurrencyRepositoryImpl({
    required this.localDataSource,
    required this.prefs,
  });

  @override
  Future<List<Currency>> getAllCurrencies() async {
    if (_cachedModels == null) {
      try {
        final jsonList = await localDataSource.getCurrencies();
        _cachedModels =
            jsonList.map((json) => CurrencyModel.fromJson(json)).toList();
      } catch (e) {
        throw CacheException('Failed to load currencies: $e');
      }
    }

    // Get the currently selected currency code from shared preferences
    final selectedCurrencyCode = prefs.getString(_selectedCurrencyKey);

    // Convert models to entities and set isSelected based on the stored preference
    return _cachedModels!.map((model) {
      return model.toEntity().copyWith(
            isSelected: model.code == selectedCurrencyCode,
          );
    }).toList();
  }

  @override
  Future<Currency?> getSelectedCurrency() async {
    try {
      final selectedCurrencyCode = prefs.getString(_selectedCurrencyKey);
      
      if (selectedCurrencyCode == null) {
        // No currency selected, get all currencies and return the first one
        final allCurrencies = await getAllCurrencies();
        return allCurrencies.isNotEmpty ? allCurrencies.first : null;
      }

      // Get all currencies to find the selected one
      final allCurrencies = await getAllCurrencies();
      final selectedCurrency = allCurrencies.firstWhere(
        (currency) => currency.code == selectedCurrencyCode,
        orElse: () => allCurrencies.isNotEmpty 
            ? allCurrencies.first 
            : throw Exception('No currencies available'),
      );
      return selectedCurrency;
    } catch (e) {
      // Return null on error
      return null;
    }
  }

  @override
  Future<List<Currency>> searchCurrencies(String query) async {
    if (_cachedModels == null) {
      await getAllCurrencies();
    }

    if (_cachedModels == null) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();

    // Get the currently selected currency so the search results can
    // correctly mark it. Without this, any search would return currencies
    // with `isSelected` set to false even if one is already chosen.
    final selectedCurrencyCode = prefs.getString(_selectedCurrencyKey);

    return _cachedModels!
        .where((currency) =>
            currency.code.toLowerCase().contains(lowercaseQuery) ||
            currency.countryName.toLowerCase().contains(lowercaseQuery))
        .map((model) => model.toEntity().copyWith(
              isSelected: model.code == selectedCurrencyCode,
            ))
        .toList();
  }

  @override
  Future<void> setSelectedCurrency(Currency currency) async {
    try {
      await prefs.setString(_selectedCurrencyKey, currency.code);
    } catch (e) {
      throw CacheException('Failed to save selected currency');
    }
  }
}
