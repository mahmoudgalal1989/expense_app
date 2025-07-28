import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart'
    as search_usecase;

import 'bloc.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final Command<List<Currency>, NoParams> getAllCurrencies;
  final Command<void, SetSelectedCurrencyParams> setSelectedCurrency;
  final Command<List<Currency>, search_usecase.SearchCurrenciesParams>
      searchCurrencies;

  CurrencyBloc({
    required this.getAllCurrencies,
    required this.setSelectedCurrency,
    required this.searchCurrencies,
  }) : super(const CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
    on<SearchCurrencies>(_onSearchCurrencies);
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final result = await getAllCurrencies(const NoParams());

    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (currencies) {
        if (currencies.isEmpty) {
          emit(const CurrencyError('No currencies available'));
        } else {
          final selectedCurrency = currencies.firstWhere(
            (c) => c.isSelected,
            orElse: () => currencies.first,
          );

          final mostUsedCurrencies =
              currencies.where((currency) => currency.isMostUsed).toList();

          emit(CurrenciesLoaded(
            currencies: currencies,
            mostUsedCurrencies: mostUsedCurrencies,
            selectedCurrency: selectedCurrency,
          ));
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
      (currency) => currency.code == event.currencyCode,
      orElse: () => currentState.selectedCurrency,
    );

    if (selectedCurrency == currentState.selectedCurrency) return;

    // Update the state with the new selected currency
    emit(currentState.copyWith(
      selectedCurrency: selectedCurrency,
    ));

    // Save the selected currency
    final result =
        await setSelectedCurrency(SetSelectedCurrencyParams(selectedCurrency));
    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (_) {
        // The state is already updated above
      },
    );
  }

  Future<void> _onSearchCurrencies(
    SearchCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    if (event.query.isEmpty) {
      if (state is CurrenciesLoaded) {
        final currentState = state as CurrenciesLoaded;
        emit(currentState);
      }
      return;
    }

    final result = await searchCurrencies(
        search_usecase.SearchCurrenciesParams(event.query));
    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (filteredCurrencies) {
        if (state is! CurrenciesLoaded) return;
        final currentState = state as CurrenciesLoaded;

        if (filteredCurrencies.isEmpty) {
          emit(CurrencyError('No currencies found for "${event.query}"'));
        } else {
          emit(SearchResultsLoaded(
            searchResults: filteredCurrencies,
            query: event.query,
            selectedCurrency: currentState.selectedCurrency,
          ));
        }
      },
    );
  }
}
