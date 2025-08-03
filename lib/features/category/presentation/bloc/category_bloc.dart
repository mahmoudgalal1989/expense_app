import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/category/domain/usecases/get_suggested_categories.dart';
import 'package:expense_app/features/category/domain/usecases/add_user_category.dart';
import 'package:expense_app/features/category/domain/usecases/manage_user_categories.dart';
import 'package:expense_app/features/category/presentation/bloc/category_event.dart';
import 'package:expense_app/features/category/presentation/bloc/category_state.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetSuggestedCategories getSuggestedCategories;
  final AddUserCategory addUserCategory;
  final ManageUserCategories manageUserCategories;
  CategoryType _currentType = CategoryType.expense;

  CategoryBloc({
    required this.getSuggestedCategories,
    required this.addUserCategory,
    required this.manageUserCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<ReorderUserCategories>(_onReorderUserCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    _currentType = event.type;
    
    // Only emit loading state if we don't have any data yet (initial load)
    if (state is CategoryInitial) {
      emit(CategoryLoading());
    }
    
    try {
      final suggested = await getSuggestedCategories(event.type);
      final userCategories = await manageUserCategories.getUserCategories(event.type);
      
      // Filter out suggested categories that are already selected by user
      final userCategoryIds = userCategories.map((c) => c.id).toSet();
      final filteredSuggested = suggested.where((c) => !userCategoryIds.contains(c.id)).toList();
      
      emit(CategoryLoaded(
        suggestedCategories: filteredSuggested,
        userCategories: userCategories,
      ));
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
        await manageUserCategories.addUserCategory(event.category, _currentType);
        
        // Reload categories to get updated data with proper order and colors
        final userCategories = await manageUserCategories.getUserCategories(_currentType);
        final updatedSuggestedCategories =
            List<Category>.from(currentState.suggestedCategories)
              ..removeWhere((c) => c.id == event.category.id);

        emit(CategoryLoaded(
          suggestedCategories: updatedSuggestedCategories,
          userCategories: userCategories,
        ));
      } catch (e) {
        emit(CategoryError('Failed to add category: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  Future<void> _onReorderUserCategories(
    ReorderUserCategories event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      
      // Optimistically update the UI first
      final updatedUserCategories = List<Category>.from(currentState.userCategories);
      final item = updatedUserCategories.removeAt(event.oldIndex);
      updatedUserCategories.insert(event.newIndex, item);
      
      // Emit the optimistic update immediately
      emit(CategoryLoaded(
        suggestedCategories: currentState.suggestedCategories,
        userCategories: updatedUserCategories,
      ));
      
      // Then persist the changes in the background
      try {
        await manageUserCategories.reorderUserCategories(
          currentState.userCategories,
          event.oldIndex,
          event.newIndex,
          _currentType,
        );
      } catch (e) {
        // If persistence fails, revert to the original state
        emit(CategoryError('Failed to reorder categories: ${e.toString()}'));
        emit(currentState);
      }
    }
  }
}
