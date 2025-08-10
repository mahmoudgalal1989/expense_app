import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

/// Handler for category-related settings events
/// Follows Single Responsibility Principle - only handles category operations
class CategoryAddedHandler extends SettingsHandler<CategoryAdded> {
  final CategoryRepository _categoryRepository;

  CategoryAddedHandler({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    CategoryAdded event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    if (currentState is! AppSettingsLoaded) return;

    emit(CategoriesUpdating(
      currentState: currentState,
      type: event.category.type,
    ));

    try {
      await _categoryRepository.addUserCategory(event.category, event.category.type);

      // Reload categories to get updated list
      final expenseCategories = await _categoryRepository.getUserCategories(CategoryType.expense);
      final incomeCategories = await _categoryRepository.getUserCategories(CategoryType.income);

      emit(AppSettingsLoaded(
        selectedCurrency: currentState.selectedCurrency,
        availableCurrencies: currentState.availableCurrencies,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        suggestedExpenseCategories: currentState.suggestedExpenseCategories,
        suggestedIncomeCategories: currentState.suggestedIncomeCategories,
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to add category: $error',
      ));
    }
  }

  @override
  int get priority => 3;
}

/// Handler for category updates
class CategoryUpdatedHandler extends SettingsHandler<CategoryUpdated> {
  final CategoryRepository _categoryRepository;

  CategoryUpdatedHandler({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    CategoryUpdated event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    if (currentState is! AppSettingsLoaded) return;

    emit(CategoriesUpdating(
      currentState: currentState,
      type: event.category.type,
    ));

    try {
      await _categoryRepository.updateUserCategory(event.category, event.category.type);

      // Reload categories to get updated list
      final expenseCategories = await _categoryRepository.getUserCategories(CategoryType.expense);
      final incomeCategories = await _categoryRepository.getUserCategories(CategoryType.income);

      emit(AppSettingsLoaded(
        selectedCurrency: currentState.selectedCurrency,
        availableCurrencies: currentState.availableCurrencies,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        suggestedExpenseCategories: currentState.suggestedExpenseCategories,
        suggestedIncomeCategories: currentState.suggestedIncomeCategories,
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to update category: $error',
      ));
    }
  }

  @override
  int get priority => 3;
}

/// Handler for category removal
class CategoryRemovedHandler extends SettingsHandler<CategoryRemoved> {
  final CategoryRepository _categoryRepository;

  CategoryRemovedHandler({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    CategoryRemoved event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    if (currentState is! AppSettingsLoaded) return;

    emit(CategoriesUpdating(
      currentState: currentState,
      type: event.type,
    ));

    try {
      await _categoryRepository.removeUserCategory(event.categoryId, event.type);

      // Reload categories to get updated list
      final expenseCategories = await _categoryRepository.getUserCategories(CategoryType.expense);
      final incomeCategories = await _categoryRepository.getUserCategories(CategoryType.income);

      emit(AppSettingsLoaded(
        selectedCurrency: currentState.selectedCurrency,
        availableCurrencies: currentState.availableCurrencies,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        suggestedExpenseCategories: currentState.suggestedExpenseCategories,
        suggestedIncomeCategories: currentState.suggestedIncomeCategories,
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to remove category: $error',
      ));
    }
  }

  @override
  int get priority => 3;
}

/// Handler for category reordering
class CategoriesReorderedHandler extends SettingsHandler<CategoriesReordered> {
  final CategoryRepository _categoryRepository;

  CategoriesReorderedHandler({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    CategoriesReordered event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    if (currentState is! AppSettingsLoaded) return;

    try {
      // For reordering, we need to determine old and new indices
      // This is a simplified implementation - in practice, you'd pass the actual indices
      await _categoryRepository.reorderUserCategories(event.reorderedCategories, 0, 1, event.type);

      // Update state with reordered categories
      final updatedExpenseCategories = event.reorderedCategories.where((c) => c.type == CategoryType.expense).toList();
      final updatedIncomeCategories = event.reorderedCategories.where((c) => c.type == CategoryType.income).toList();

      emit(AppSettingsLoaded(
        selectedCurrency: currentState.selectedCurrency,
        availableCurrencies: currentState.availableCurrencies,
        expenseCategories: updatedExpenseCategories,
        incomeCategories: updatedIncomeCategories,
        suggestedExpenseCategories: currentState.suggestedExpenseCategories,
        suggestedIncomeCategories: currentState.suggestedIncomeCategories,
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to reorder categories: $error',
      ));
    }
  }

  @override
  int get priority => 3;
}
