part of 'currency_bloc.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object> get props => [];
}

class LoadCurrencies extends CurrencyEvent {
  const LoadCurrencies();
}

class SelectCurrency extends CurrencyEvent {
  final String currencyCode;

  const SelectCurrency(this.currencyCode);

  @override
  List<Object> get props => [currencyCode];
}

class LoadMostUsedCurrencies extends CurrencyEvent {
  const LoadMostUsedCurrencies();
}
