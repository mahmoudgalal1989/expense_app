import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

/// Handler for resetting app settings to defaults
/// Follows Single Responsibility Principle - only handles reset operations
class ResetSettingsHandler extends SettingsHandler<ResetAppSettings> {
  final CurrencyRepository _currencyRepository;
  final CategoryRepository _categoryRepository;

  ResetSettingsHandler({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
  })  : _currencyRepository = currencyRepository,
        _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    ResetAppSettings event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    emit(const AppSettingsLoading());

    try {
      // Reset currency to default (first available)
      final currencies = await _currencyRepository.getAllCurrencies();
      if (currencies.isNotEmpty) {
        await _currencyRepository.setSelectedCurrency(currencies.first);
      }

      // Clear user categories (reset to suggested only)
      await _categoryRepository.clearUserCategories(CategoryType.expense);
      await _categoryRepository.clearUserCategories(CategoryType.income);

      // Trigger reinitialization
      emit(const AppSettingsInitial());
    } catch (error) {
      emit(AppSettingsError(
        'Failed to reset app settings: $error',
      ));
    }
  }

  @override
  int get priority => 10; // Lower priority for reset operations
}
