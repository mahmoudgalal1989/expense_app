import 'package:equatable/equatable.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final CategoryType type;

  const LoadCategories(this.type);

  @override
  List<Object> get props => [type];
}

class AddCategory extends CategoryEvent {
  final Category category;

  const AddCategory(this.category);

  @override
  List<Object> get props => [category];
}
