import 'package:expense_app/features/category/data/models/category_model.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getSuggestedCategories(CategoryType type);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
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
      ],
      CategoryType.income: [
        const CategoryModel(
            id: '7', name: 'Salary', icon: '💰', type: CategoryType.income),
        const CategoryModel(
            id: '8', name: 'Freelance', icon: '💼', type: CategoryType.income),
        const CategoryModel(
            id: '9', name: 'Investment', icon: '📈', type: CategoryType.income),
        const CategoryModel(
            id: '10', name: 'Gift', icon: '🎁', type: CategoryType.income),
      ],
    };

    return allCategories[type] ?? [];
  }
}
