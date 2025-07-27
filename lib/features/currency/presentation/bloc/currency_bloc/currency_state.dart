part of 'currency_bloc.dart';

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

  const CurrenciesLoaded({
    required this.currencies,
    this.mostUsedCurrencies = const [],
  });

  @override
  List<Object> get props => [currencies, mostUsedCurrencies];

  CurrenciesLoaded copyWith({
    List<Currency>? currencies,
    List<Currency>? mostUsedCurrencies,
  }) {
    return CurrenciesLoaded(
      currencies: currencies ?? this.currencies,
      mostUsedCurrencies: mostUsedCurrencies ?? this.mostUsedCurrencies,
    );
  }
}

class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object> get props => [message];
}
