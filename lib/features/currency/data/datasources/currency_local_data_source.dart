import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:expense_app/core/error/exceptions.dart';

/// Contract for local data source that handles currency data operations
abstract class CurrencyLocalDataSource {
  /// Loads currencies from the local data source
  /// 
  /// Returns a list of currency data as a list of maps
  /// 
  /// Throws a [CacheException] if there's an error loading or parsing the data
  Future<List<Map<String, dynamic>>> getCurrencies();
}

/// Implementation of [CurrencyLocalDataSource] that loads currency data from a JSON file
class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  static const String _currenciesPath = 'assets/data/currencies.json';

  @override
  Future<List<Map<String, dynamic>>> getCurrencies() async {
    try {
      // Load the JSON file as a string
      final jsonString = await rootBundle.loadString(_currenciesPath);
      
      // Parse the JSON string into a list of dynamic objects
      final List<dynamic> jsonList;
      try {
        jsonList = json.decode(jsonString) as List;
      } catch (e) {
        throw const FormatException('Invalid JSON format in currencies file');
      }
      
      // Convert each item in the list to a Map<String, dynamic>
      return jsonList.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a list of currency objects');
        }
        return item;
      }).toList();
    } on PlatformException catch (e) {
      throw CacheException('Failed to load currency data: ${e.message}');
    } on FormatException catch (e) {
      throw CacheException('Invalid currency data format: ${e.message}');
    } catch (e) {
      throw CacheException('Unexpected error loading currencies: $e');
    }
  }
}
