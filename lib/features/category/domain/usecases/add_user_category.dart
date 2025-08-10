import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

class AddUserCategory {
  final CategoryRepository repository;

  AddUserCategory(this.repository);

  Future<void> call(Category category, CategoryType type) async {
    await repository.addUserCategory(category, type);
  }
}
