import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/category/domain/usecases/get_suggested_categories.dart';
import 'package:expense_app/features/category/domain/usecases/add_user_category.dart';
import 'package:expense_app/features/category/presentation/bloc/category_event.dart';
import 'package:expense_app/features/category/presentation/bloc/category_state.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetSuggestedCategories getSuggestedCategories;
  final AddUserCategory addUserCategory;

  CategoryBloc({
    required this.getSuggestedCategories,
    required this.addUserCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final suggested = await getSuggestedCategories(event.type);
      // In a real app, you would also fetch user categories here.
      emit(CategoryLoaded(
          suggestedCategories: suggested, userCategories: const []));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      try {
        await addUserCategory(event.category);
        // Optimistically update the UI
        final updatedUserCategories =
            List<Category>.from(currentState.userCategories)
              ..add(event.category);
        final updatedSuggestedCategories =
            List<Category>.from(currentState.suggestedCategories)
              ..removeWhere((c) => c.id == event.category.id);

        emit(CategoryLoaded(
          suggestedCategories: updatedSuggestedCategories,
          userCategories: updatedUserCategories,
        ));
      } catch (e) {
        // If adding fails, you might want to revert the state
        emit(CategoryError('Failed to add category: ${e.toString()}'));
        // Re-emit the previous state to revert optimistic update
        emit(currentState);
      }
    }
  }
}
