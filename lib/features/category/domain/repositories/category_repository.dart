import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getSuggestedCategories(CategoryType type);
  Future<void> addUserCategory(Category category, CategoryType type);
  Future<List<Category>> getUserCategories(CategoryType type);
  Future<void> updateUserCategory(Category category, CategoryType type);
  Future<void> removeUserCategory(String categoryId, CategoryType type);
  Future<void> reorderUserCategories(List<Category> categories, int oldIndex, int newIndex, CategoryType type);
  Future<void> clearUserCategories(CategoryType type);
}
