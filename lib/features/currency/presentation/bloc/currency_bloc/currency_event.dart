import 'package:equatable/equatable.dart';

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

class SearchCurrencies extends CurrencyEvent {
  final String query;

  const SearchCurrencies(this.query);

  @override
  List<Object> get props => [query];
}
