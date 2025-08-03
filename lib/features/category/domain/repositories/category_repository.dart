import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getSuggestedCategories(CategoryType type);
  Future<void> addUserCategory(Category category);
  Future<List<Category>> getUserCategories(CategoryType type);
}
