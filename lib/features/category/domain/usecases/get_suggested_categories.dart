import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

class GetSuggestedCategories {
  final CategoryRepository repository;

  GetSuggestedCategories(this.repository);

  Future<List<Category>> call(CategoryType type) async {
    return await repository.getSuggestedCategories(type);
  }
}
