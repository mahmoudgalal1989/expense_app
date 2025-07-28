import 'package:equatable/equatable.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrenciesLoaded extends CurrencyState {
  final List<Currency> currencies;
  final List<Currency> mostUsedCurrencies;
  final Currency selectedCurrency;

  const CurrenciesLoaded({
    required this.currencies,
    this.mostUsedCurrencies = const [],
    required this.selectedCurrency,
  });

  @override
  List<Object> get props => [currencies, mostUsedCurrencies, selectedCurrency];

  CurrenciesLoaded copyWith({
    List<Currency>? currencies,
    List<Currency>? mostUsedCurrencies,
    Currency? selectedCurrency,
  }) {
    return CurrenciesLoaded(
      currencies: currencies ?? this.currencies,
      mostUsedCurrencies: mostUsedCurrencies ?? this.mostUsedCurrencies,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }
}

class SearchResultsLoaded extends CurrencyState {
  final List<Currency> searchResults;
  final String query;
  final Currency selectedCurrency;

  const SearchResultsLoaded({
    required this.searchResults,
    required this.query,
    required this.selectedCurrency,
  });

  @override
  List<Object> get props => [searchResults, query, selectedCurrency];
}

class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object> get props => [message];
}
