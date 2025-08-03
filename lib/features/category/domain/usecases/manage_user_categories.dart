import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/data/datasources/category_persistence_data_source.dart';
import 'package:expense_app/features/category/data/models/category_model.dart';
import 'package:flutter/material.dart';

class ManageUserCategories {
  final CategoryPersistenceDataSource persistenceDataSource;

  ManageUserCategories(this.persistenceDataSource);

  // Predefined border colors
  static const List<Color> borderColors = [
    Color(0xFF6366F1), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Yellow
    Color(0xFFEC4899), // Pink
  ];

  Future<List<Category>> getUserCategories(CategoryType type) async {
    final categories = await persistenceDataSource.getUserCategories(type);
    // Sort by order if available
    categories.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return categories;
  }

  Future<void> addUserCategory(Category category, CategoryType type) async {
    final existingCategories = await persistenceDataSource.getUserCategories(type);
    
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
    await persistenceDataSource.saveUserCategories(updatedCategories, type);
  }

  Future<void> reorderUserCategories(
    List<Category> categories,
    int oldIndex,
    int newIndex,
    CategoryType type,
  ) async {
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
    
    await persistenceDataSource.saveUserCategories(categoriesWithNewOrder, type);
  }

  Future<void> removeUserCategory(String categoryId, CategoryType type) async {
    final existingCategories = await persistenceDataSource.getUserCategories(type);
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
    
    await persistenceDataSource.saveUserCategories(categoriesWithNewOrder, type);
  }

  Future<void> clearUserCategories(CategoryType type) async {
    await persistenceDataSource.clearUserCategories(type);
  }
}
