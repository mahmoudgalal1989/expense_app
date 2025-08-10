import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';


/// Handler for currency-related settings events
/// Follows Single Responsibility Principle - only handles currency operations
class CurrencySettingsHandler extends SettingsHandler<CurrencyChanged> {
  final CurrencyRepository _currencyRepository;

  CurrencySettingsHandler({
    required CurrencyRepository currencyRepository,
  }) : _currencyRepository = currencyRepository;

  @override
  Future<void> handle(
    CurrencyChanged event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    if (currentState is! AppSettingsLoaded) return;

    emit(CurrencyUpdating(currentState));

    try {
      await _currencyRepository.setSelectedCurrency(event.currency);

      emit(AppSettingsLoaded(
        selectedCurrency: event.currency,
        availableCurrencies: currentState.availableCurrencies,
        expenseCategories: currentState.expenseCategories,
        incomeCategories: currentState.incomeCategories,
        suggestedExpenseCategories: currentState.suggestedExpenseCategories,
        suggestedIncomeCategories: currentState.suggestedIncomeCategories,
      ));
    } catch (error) {
      emit(AppSettingsError(
        'Failed to update currency: $error',
      ));
    }
  }

  @override
  int get priority => 1;
}

/// Handler for loading currencies
class LoadCurrenciesHandler extends SettingsHandler<LoadCurrencies> {
  final CurrencyRepository _currencyRepository;

  LoadCurrenciesHandler({
    required CurrencyRepository currencyRepository,
  }) : _currencyRepository = currencyRepository;

  @override
  Future<void> handle(
    LoadCurrencies event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    try {
      final currencies = await _currencyRepository.getAllCurrencies();
      final selectedCurrency = await _currencyRepository.getSelectedCurrency();

      if (currentState is AppSettingsLoaded) {
        emit(AppSettingsLoaded(
          selectedCurrency: selectedCurrency ?? (currencies.isNotEmpty ? currencies.first : currencies.first),
          availableCurrencies: currencies,
          expenseCategories: currentState.expenseCategories,
          incomeCategories: currentState.incomeCategories,
          suggestedExpenseCategories: currentState.suggestedExpenseCategories,
          suggestedIncomeCategories: currentState.suggestedIncomeCategories,
        ));
      }
    } catch (error) {
      emit(AppSettingsError(
        'Failed to load currencies: $error',
      ));
    }
  }

  @override
  int get priority => 2;
}
