import 'package:expense_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/category/data/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  // Predefined border colors
  static const List<Color> borderColors = [
    Color(0xFF6366F1), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Yellow
    Color(0xFFEC4899), // Pink
  ];

  CategoryRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Category>> getSuggestedCategories(CategoryType type) async {
    return await localDataSource.getSuggestedCategories(type);
  }

  @override
  Future<List<Category>> getUserCategories(CategoryType type) async {
    final categories = await localDataSource.getUserCategories(type);
    // Sort by order if available
    categories.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return categories;
  }

  @override
  Future<void> addUserCategory(Category category, CategoryType type) async {
    final existingCategories = await localDataSource.getUserCategories(type);
    
    // Assign border color and order
    final borderColor = borderColors[existingCategories.length % borderColors.length];
    final order = existingCategories.length;
    
    final categoryWithMetadata = CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      type: category.type,
      borderColor: borderColor,
      order: order,
    );
    
    final updatedCategories = [...existingCategories, categoryWithMetadata];
    await localDataSource.saveUserCategories(updatedCategories, type);
  }

  @override
  Future<void> updateUserCategory(Category category, CategoryType type) async {
    final existingCategories = await localDataSource.getUserCategories(type);
    
    // Find the existing category to preserve its order and border color
    final existingCategoryIndex = existingCategories.indexWhere((c) => c.id == category.id);
    if (existingCategoryIndex == -1) {
      throw Exception('Category not found');
    }
    
    final existingCategory = existingCategories[existingCategoryIndex];
    
    final updatedCategory = CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      type: category.type,
      borderColor: category.borderColor ?? existingCategory.borderColor,
      order: existingCategory.order,
    );
    
    final updatedCategories = List<CategoryModel>.from(existingCategories.cast<CategoryModel>());
    updatedCategories[existingCategoryIndex] = updatedCategory;
    
    await localDataSource.saveUserCategories(updatedCategories, type);
  }

  @override
  Future<void> reorderUserCategories(List<Category> categories, int oldIndex, int newIndex, CategoryType type) async {
    final reorderedCategories = List<Category>.from(categories);
    final item = reorderedCategories.removeAt(oldIndex);
    reorderedCategories.insert(newIndex, item);
    
    // Update order indices
    final categoriesWithNewOrder = reorderedCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return CategoryModel(
        id: category.id,
        name: category.name,
        icon: category.icon,
        type: category.type,
        borderColor: category.borderColor,
        order: index,
      );
    }).toList();
    
    await localDataSource.saveUserCategories(categoriesWithNewOrder, type);
  }

  @override
  Future<void> removeUserCategory(String categoryId, CategoryType type) async {
    final existingCategories = await localDataSource.getUserCategories(type);
    final updatedCategories = existingCategories
        .where((category) => category.id != categoryId)
        .toList();
    
    // Reassign order indices after removal
    final categoriesWithNewOrder = updatedCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return CategoryModel(
        id: category.id,
        name: category.name,
        icon: category.icon,
        type: category.type,
        borderColor: category.borderColor,
        order: index,
      );
    }).toList();
    
    await localDataSource.saveUserCategories(categoriesWithNewOrder, type);
  }

  @override
  Future<void> clearUserCategories(CategoryType type) async {
    await localDataSource.clearUserCategories(type);
  }
}
