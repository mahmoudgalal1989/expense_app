import 'package:expense_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getSuggestedCategories(CategoryType type) async {
    return await localDataSource.getSuggestedCategories(type);
  }

  @override
  Future<void> addUserCategory(Category category) async {
    // TODO: Implement logic to add user category to a persistent storage
  }

  @override
  Future<List<Category>> getUserCategories(CategoryType type) async {
    // TODO: Implement logic to fetch user categories from a persistent storage
    return [];
  }
}
