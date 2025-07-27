import 'dart:convert';
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
    return _cachedModels!.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Currency>> getMostUsedCurrencies() async {
    final allCurrencies = await getAllCurrencies();
    return allCurrencies.where((currency) => currency.isMostUsed).toList();
  }

  @override
  Future<void> setSelectedCurrency(Currency currency) async {
    await prefs.setString(_selectedCurrencyKey, currency.code);
    
    // Update the selected status in the cached models
    _cachedModels = _cachedModels?.map((model) {
      return model.copyWith(
        isSelected: model.code == currency.code,
      );
    }).toList();
  }
}
