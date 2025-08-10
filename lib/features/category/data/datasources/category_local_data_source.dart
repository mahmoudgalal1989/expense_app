import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_app/features/category/data/models/category_model.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getSuggestedCategories(CategoryType type);
  Future<List<CategoryModel>> getUserCategories(CategoryType type);
  Future<void> saveUserCategories(List<CategoryModel> categories, CategoryType type);
  Future<void> clearUserCategories(CategoryType type);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  static const String _expenseCategoriesKey = 'user_expense_categories';
  static const String _incomeCategoriesKey = 'user_income_categories';

  String _getKeyForType(CategoryType type) {
    return type == CategoryType.expense ? _expenseCategoriesKey : _incomeCategoriesKey;
  }

  @override
  Future<List<CategoryModel>> getSuggestedCategories(CategoryType type) async {
    // Simulate a network or database call
    await Future.delayed(const Duration(milliseconds: 500));

    final allCategories = {
      CategoryType.expense: [
        const CategoryModel(
            id: '1', name: 'Housing', icon: '🏡', type: CategoryType.expense),
        const CategoryModel(
            id: '2', name: 'Food', icon: '🍔', type: CategoryType.expense),
        const CategoryModel(
            id: '3', name: 'Groceries', icon: '🛒', type: CategoryType.expense),
        const CategoryModel(
            id: '4',
            name: 'Transportation',
            icon: '🚗',
            type: CategoryType.expense),
        const CategoryModel(
            id: '5', name: 'Bills', icon: '🧾', type: CategoryType.expense),
        const CategoryModel(
            id: '6', name: 'Shopping', icon: '🛍️', type: CategoryType.expense),
        const CategoryModel(
            id: '7', name: 'Extras', icon: '✨', type: CategoryType.expense),
        const CategoryModel(
            id: '8', name: 'Clothing', icon: '👕', type: CategoryType.expense),
        const CategoryModel(
            id: '9', name: 'Taxi', icon: '🚕', type: CategoryType.expense),
        const CategoryModel(
            id: '10', name: 'Going out', icon: '🎉', type: CategoryType.expense),
        const CategoryModel(
            id: '11', name: 'Entertainment', icon: '🎬', type: CategoryType.expense),
        const CategoryModel(
            id: '12', name: 'Subscription', icon: '📱', type: CategoryType.expense),
        const CategoryModel(
            id: '13', name: 'Miscellaneous', icon: '📁', type: CategoryType.expense),
        const CategoryModel(
            id: '14', name: 'Loan', icon: '🏦', type: CategoryType.expense),
        const CategoryModel(
            id: '15', name: 'Utilities', icon: '💡', type: CategoryType.expense),
        const CategoryModel(
            id: '16', name: 'Healthcare', icon: '🏥', type: CategoryType.expense),
        const CategoryModel(
            id: '17', name: 'Pets', icon: '🐕', type: CategoryType.expense),
        const CategoryModel(
            id: '18', name: 'Gifts', icon: '🎁', type: CategoryType.expense),
        const CategoryModel(
            id: '19', name: 'Travel', icon: '✈️', type: CategoryType.expense),
      ],
      CategoryType.income: [
        const CategoryModel(
            id: '20', name: 'Salary', icon: '💰', type: CategoryType.income),
        const CategoryModel(
            id: '21', name: 'Part-Time', icon: '💼', type: CategoryType.income),
        const CategoryModel(
            id: '22', name: 'Investments', icon: '📈', type: CategoryType.income),
        const CategoryModel(
            id: '23', name: 'Allowance', icon: '💵', type: CategoryType.income),
        const CategoryModel(
            id: '24', name: 'Gift', icon: '🎁', type: CategoryType.income),
        const CategoryModel(
            id: '25', name: 'Tips', icon: '🪙', type: CategoryType.income),
      ],
    };

    return allCategories[type] ?? [];
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
