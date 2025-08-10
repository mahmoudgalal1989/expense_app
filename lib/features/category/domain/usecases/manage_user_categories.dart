import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

class ManageUserCategories {
  final CategoryRepository repository;

  ManageUserCategories(this.repository);

  Future<List<Category>> getUserCategories(CategoryType type) async {
    return await repository.getUserCategories(type);
  }

  Future<void> addUserCategory(Category category, CategoryType type) async {
    await repository.addUserCategory(category, type);
  }

  Future<void> updateUserCategory(Category category, CategoryType type) async {
    await repository.updateUserCategory(category, type);
  }

  Future<void> reorderUserCategories(
    List<Category> categories,
    int oldIndex,
    int newIndex,
    CategoryType type,
  ) async {
    await repository.reorderUserCategories(categories, oldIndex, newIndex, type);
  }

  Future<void> removeUserCategory(String categoryId, CategoryType type) async {
    await repository.removeUserCategory(categoryId, type);
  }

  Future<void> clearUserCategories(CategoryType type) async {
    await repository.clearUserCategories(type);
  }
}
