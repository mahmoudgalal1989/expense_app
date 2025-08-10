import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

/// Handler for app settings initialization
/// Follows Single Responsibility Principle - only handles initialization
class InitializationHandler extends SettingsHandler<InitializeAppSettings>
    implements SettingsDataLoader {
  final CurrencyRepository _currencyRepository;
  final CategoryRepository _categoryRepository;

  InitializationHandler({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
  })  : _currencyRepository = currencyRepository,
        _categoryRepository = categoryRepository;

  @override
  Future<void> handle(
    InitializeAppSettings event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    emit(const AppSettingsLoading());

    try {
      final data = await loadInitialData();

      emit(AppSettingsLoaded(
        selectedCurrency: data['selectedCurrency'],
        availableCurrencies: data['availableCurrencies'],
        expenseCategories: data['expenseCategories'],
        incomeCategories: data['incomeCategories'],
        suggestedExpenseCategories: data['suggestedExpenseCategories'],
        suggestedIncomeCategories: data['suggestedIncomeCategories'],
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to initialize app settings: $error',
      ));
    }
  }

  @override
  Future<Map<String, dynamic>> loadInitialData() async {
    // Load all data concurrently for better performance
    final results = await Future.wait([
      _currencyRepository.getAllCurrencies(),
      _currencyRepository.getSelectedCurrency(),
      _categoryRepository.getUserCategories(CategoryType.expense),
      _categoryRepository.getUserCategories(CategoryType.income),
      _categoryRepository.getSuggestedCategories(CategoryType.expense),
      _categoryRepository.getSuggestedCategories(CategoryType.income),
    ]);

    final currencies = results[0] as List;
    final selectedCurrency = results[1];
    final expenseCategories = results[2] as List;
    final incomeCategories = results[3] as List;
    final suggestedExpenseCategories = results[4] as List;
    final suggestedIncomeCategories = results[5] as List;

    return {
      'selectedCurrency': selectedCurrency ?? (currencies.isNotEmpty ? currencies.first : null),
      'availableCurrencies': currencies,
      'expenseCategories': expenseCategories,
      'incomeCategories': incomeCategories,
      'suggestedExpenseCategories': suggestedExpenseCategories,
      'suggestedIncomeCategories': suggestedIncomeCategories,
    };
  }

  @override
  int get priority => 0; // Highest priority for initialization
}
