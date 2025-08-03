import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_app/features/category/data/models/category_model.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryPersistenceDataSource {
  Future<List<CategoryModel>> getUserCategories(CategoryType type);
  Future<void> saveUserCategories(List<CategoryModel> categories, CategoryType type);
  Future<void> clearUserCategories(CategoryType type);
}

class CategoryPersistenceDataSourceImpl implements CategoryPersistenceDataSource {
  static const String _expenseCategoriesKey = 'user_expense_categories';
  static const String _incomeCategoriesKey = 'user_income_categories';

  String _getKeyForType(CategoryType type) {
    return type == CategoryType.expense ? _expenseCategoriesKey : _incomeCategoriesKey;
  }

  @override
  Future<List<CategoryModel>> getUserCategories(CategoryType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForType(type);
      final categoriesJson = prefs.getString(key);
      
      if (categoriesJson == null) {
        return [];
      }
      
      final List<dynamic> categoriesList = json.decode(categoriesJson);
      return categoriesList
          .map((categoryJson) => CategoryModel.fromJson(categoryJson))
          .toList();
    } catch (e) {
      // If there's an error reading from SharedPreferences, return empty list
      return [];
    }
  }

  @override
  Future<void> saveUserCategories(List<CategoryModel> categories, CategoryType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForType(type);
      final categoriesJson = json.encode(
        categories.map((category) => category.toJson()).toList(),
      );
      await prefs.setString(key, categoriesJson);
    } catch (e) {
      // Handle error - could throw custom exception or log
      throw Exception('Failed to save categories: $e');
    }
  }

  @override
  Future<void> clearUserCategories(CategoryType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForType(type);
      await prefs.remove(key);
    } catch (e) {
      // Handle error - could throw custom exception or log
      throw Exception('Failed to clear categories: $e');
    }
  }
}
