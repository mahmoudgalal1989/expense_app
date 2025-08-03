import 'package:equatable/equatable.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> suggestedCategories;
  final List<Category> userCategories;

  const CategoryLoaded({
    required this.suggestedCategories,
    required this.userCategories,
  });

  @override
  List<Object> get props => [suggestedCategories, userCategories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
