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
        _cachedModels = jsonList
            .map((json) => CurrencyModel.fromJson(json))
            .toList();
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
  Future<List<Currency>> searchCurrencies(String query) async {
    if (_cachedModels == null) {
      await getAllCurrencies();
    }
    
    if (_cachedModels == null) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();
    return _cachedModels!
        .where((currency) =>
            currency.code.toLowerCase().contains(lowercaseQuery) ||
            currency.countryName.toLowerCase().contains(lowercaseQuery))
        .map((model) => model.toEntity())
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
