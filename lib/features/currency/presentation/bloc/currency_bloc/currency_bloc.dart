import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart';

// Import all bloc-related files through the barrel file
import 'bloc.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final GetAllCurrencies getAllCurrencies;
  final SetSelectedCurrency setSelectedCurrency;
  final SearchCurrenciesUseCase searchCurrenciesUseCase;
  Currency? _selectedCurrency;
  List<Currency> _allCurrencies = [];

  CurrencyBloc({
    required this.getAllCurrencies,
    required this.setSelectedCurrency,
    required this.searchCurrenciesUseCase,
  }) : super(CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
    on<SearchCurrencies>(_onSearchCurrencies);
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(CurrencyLoading());

    final result = await getAllCurrencies();

    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (currencies) {
        if (currencies.isEmpty) {
          emit(const CurrencyError('No currencies available'));
        } else {
          // Update the selected currency if not set
          _selectedCurrency ??= currencies.firstWhere(
            (c) => c.isSelected,
            orElse: () => currencies.first,
          );
          _allCurrencies = List.from(currencies);
          final mostUsedCurrencies =
              currencies.where((currency) => currency.isMostUsed).toList();

          // Create a new state with the loaded currencies
          final newState = CurrenciesLoaded(
            currencies: currencies,
            mostUsedCurrencies: mostUsedCurrencies,
            selectedCurrency: _selectedCurrency!,
          );
          emit(newState);
        }
      },
    );
  }

  Future<void> _onSelectCurrency(
    SelectCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is! CurrenciesLoaded) return;

    final currentState = state as CurrenciesLoaded;
    final selectedCurrency = currentState.currencies.firstWhere(
      (c) => c.code == event.currencyCode,
      orElse: () => currentState.currencies.first,
    );

    // Update the selected currency
    _selectedCurrency = selectedCurrency;

    emit(CurrencyLoading());

    try {
      // This will persist the selected currency to shared preferences
      await setSelectedCurrency(selectedCurrency);

      // Reload currencies to get them with the updated selected state
      final result = await getAllCurrencies();

      result.fold(
        (failure) => emit(CurrencyError(failure.toString())),
        (currencies) {
          if (currencies.isEmpty) {
            emit(const CurrencyError('No currencies available'));
          } else {
            // Filter most used currencies from the updated list
            final updatedMostUsedCurrencies =
                currencies.where((currency) => currency.isMostUsed).toList();

            // Create a new state with the updated currencies and most used currencies
            final newState = currentState.copyWith(
              currencies: currencies,
              mostUsedCurrencies: updatedMostUsedCurrencies,
            );
            emit(newState);
          }
        },
      );
    } catch (e) {
      emit(CurrencyError('Failed to select currency: ${e.toString()}'));
      // Re-emit the previous state to maintain UI consistency
      emit(currentState);
    }
  }

  Future<void> _onSearchCurrencies(
    SearchCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    if (event.query.isEmpty) {
      // If search query is empty, return to the regular currencies list
      if (_allCurrencies.isNotEmpty) {
        final mostUsedCurrencies = 
            _allCurrencies.where((c) => c.isMostUsed).toList();
        emit(CurrenciesLoaded(
          currencies: _allCurrencies,
          mostUsedCurrencies: mostUsedCurrencies,
          selectedCurrency: _selectedCurrency ?? _allCurrencies.first,
        ));
      }
      return;
    }

    emit(CurrencyLoading());

    final result = await searchCurrenciesUseCase(event.query);

    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (results) {
        if (results.isEmpty) {
          emit(CurrencyError('No currencies found for "${event.query}"'));
        } else {
          emit(SearchResultsLoaded(
            searchResults: results,
            query: event.query,
            selectedCurrency: _selectedCurrency ?? results.first,
          ));
        }
      },
    );
  }
}
